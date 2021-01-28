#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <termios.h>
#include <sys/ioctl.h>
#include <pthread.h>
#include <signal.h>
#include <stdbool.h>

#include "defines.h"

// Per la gestione dei segnali
static volatile sig_atomic_t signo;
typedef struct sigaction sigaction_t;
static void handler(int s);


void handler_ign(){
	signal(SIGALRM, handler);
	signal(SIGINT, handler);
	signal(SIGHUP, handler);
	signal(SIGQUIT, handler);
	signal(SIGTERM, handler);
	signal(SIGTSTP, handler);
	signal(SIGTTIN, handler);
	signal(SIGTTOU, handler);
}


void handler_dfl(){
	signal(SIGALRM, SIG_DFL);
	signal(SIGINT, SIG_DFL);
	signal(SIGHUP, SIG_DFL);
	signal(SIGQUIT, SIG_DFL);
	signal(SIGTERM, SIG_DFL);
	signal(SIGTSTP, SIG_DFL);
	signal(SIGTTIN, SIG_DFL);
	signal(SIGTTOU, SIG_DFL);
}


char *getInput(unsigned int lung, char *stringa, bool hide)
{
	char c;
	unsigned int i;

	struct termios term, oterm;
	
	handler_ign();	// Ignora eventuali segnali 
	
	if(hide) {
		// Svuota il buffer
		(void) fflush(stdout);
	
		// Disattiva l'output su schermo
		if (tcgetattr(fileno(stdin), &oterm) == 0) {
			(void) memcpy(&term, &oterm, sizeof(struct termios));
			term.c_lflag &= ~(ECHO|ECHONL);
			(void) tcsetattr(fileno(stdin), TCSAFLUSH, &term);
		} else {
			(void) memset(&term, 0, sizeof(struct termios));
			(void) memset(&oterm, 0, sizeof(struct termios));
		}
	}
	
	// Acquisisce da tastiera al più lung - 1 caratteri
	for(i = 0; i < lung; i++) {
		(void) fread(&c, sizeof(char), 1, stdin);
		if(c == '\n') {
			stringa[i] = '\0';
			break;
		} else
			stringa[i] = c;

		// Gestisce gli asterischi
		if(hide) {
			if(c == '\b') // Backspace
				(void) write(fileno(stdout), &c, sizeof(char));
			else
				(void) write(fileno(stdout), "*", sizeof(char));
		}
	}
		
	// Se sono stati digitati più caratteri, svuota il buffer della tastiera
	if(strlen(stringa) >= lung) {	
		// Svuota il buffer della tastiera
		do {
			c = getchar();
		} while (c != '\n');
	}
	
	// Controlla che il terminatore di stringa sia stato inserito
	if(i == lung - 1)
		stringa[i] = '\0';
	
	if(hide) {
		//Va a capo dopo l'input
		(void) write(fileno(stdout), "\n", 1);

		// Ripristina le impostazioni precedenti dello schermo
		(void) tcsetattr(fileno(stdin), TCSAFLUSH, &oterm);
		
		handler_dfl(); 	// Ripristina la gestione dei segnali

		// Se era stato ricevuto un segnale viene rilanciato al processo stesso
		if(signo)
			(void) raise(signo);
	}
	
	return stringa;
}

// Scanf alternativo
char *getInputScanf(int length_max) {
	int length, i=0;
	char *stringa;
	char c;
	
	handler_ign();		// Ignora eventuali segnali
	
	length = 0;
	stringa = (char *) malloc(length_max * sizeof(char *));
	
	while(1) {
		c = getchar();
		stringa[i] = c;
		if(c == '\n') break;
		length++;
		i++;
	}
	
	stringa[length] = '\0';
	
	if(length > length_max)
		stringa[length_max-1] = '\0';
	
	handler_dfl();		// Reset di default dei segnali
	
	if(signo)
		(void) raise(signo);
	
	return stringa;
}

// Per la gestione dei segnali
static void handler(int s) {
	signo = s;
}


bool yesOrNo(char *domanda, char yes, char no) {
	
	// I caratteri 'yes' e 'no' devono essere minuscoli
	yes = tolower(yes);
	no = tolower(no);

	// Richiesta della risposta
	while(true) {
		
		printf("\e[1m%s\e[22m [\033[40m\033[1;34m%c\033[0m/\033[40m\033[1;31m%c\033[0m]: ", domanda, yes, no);	// Mostra la domanda

		char c[2];
		getInput(2, c, false);
					
		// Controlla quale risposta è stata data
		if(c[0] == yes || c[0] == toupper(yes)) 
			return true;
		else if(c[0] == no || c[0] == toupper(no)) 
			return false;
	}
}


char *string_union(char *a, char *stringa, char *b, bool first_space, bool bold) {
	int j, lenght;
	char *text;
	char *bold_a = "\e[1m";
	char *bold_b = "\e[22m";	
			
	lenght = strlen(a) + strlen(stringa) + strlen(b);
	
	// Controllo i parametri booleani in modo da regolare la dimensione dell'allocazione
	if(first_space){lenght++;}
	if(bold){lenght+= strlen(bold_a) + strlen(bold_b);}
	
	// Alloco spazio per concatenare le stringhe
	text = (char *) malloc(lenght*sizeof(char *));
		
	j = 0;	// Indice text	
	
	if(first_space){
		text[j] = '\n';
		j++;
	}
		
	if(bold){
		for(int i=0; i<(int)strlen(bold_a); i++){
			text[j] = bold_a[i];
			j++;
		}
	}
		
	for(int i=0; i<(int)strlen(a); i++){
		text[j] = a[i];
		j++;
	}
	
	for(int i=0; i<(int)strlen(stringa); i++){
		text[j] = stringa[i];
		j++;
	}
	
	for(int i=0; i<(int)strlen(b); i++){
		text[j] = b[i];
		j++;
	}
	
	if(bold){
		for(int i=0; i<(int)strlen(bold_b); i++){
			text[j] = bold_b[i];
			j++;
		}
	}
	
	text[j] = '\0';	
	
	return text;
}


char *print_color(char *colorless, char *colore_scelto, char c, bool first_space , bool bold, bool error) {
	char *text, *stringa;
	char *list_color[] = {"orange", "blue", "light blue", "red", "light red", "white", "purple", "cyan", "light cyan"};
	int i, length_list_color;
	
	if(strlen(colorless) == 0 && c == ' ') {
		print_error(NULL, "Error Parameters");
		return "Error";
	}
	
	// Il colore deve essere minuscolo
	char *colore = (char *) malloc(strlen(colore_scelto) * sizeof(char *));
	for(i=0; colore[i]; i++){
		colore[i] = tolower(colore_scelto[i]);
	}
	colore[i] = '\0';
	
	// Controllo che la variabile passata sia una stringa o un char
	if(strcmp(colorless, "") == 0) {
		stringa = (char *) malloc(2);
		stringa[0] = c;
		stringa[1] = '\0';
	} else {
		stringa = (char *) malloc(strlen(colorless)*sizeof(char *));
		strcpy(stringa, colorless);
		stringa[strlen(stringa)] = '\0';
	}
	
	// Cerco il colore
	length_list_color = 9;
	i = 0;		
	while(1) {
		if (i == length_list_color) {break;}
		if (strcmp(colore_scelto, list_color[i]) == 0) {break;}
		i++;
	}
	free(colore);
	
	// Alloco lo spazio massimo per ottenere la stringa intera da stampare
	text = (char *) malloc(strlen("\033[40m\033[1;32m\033[0m\e[1m\e[22m")+strlen(stringa));
	
	// Concatenazione delle stringhe
	switch(i) {
		case 0:
			strcpy(text, string_union("\033[40m\033[1;32m", stringa, "\033[0m", first_space, bold));
			break;
		case 1:
			strcpy(text, string_union("\033[40m\033[34m", stringa, "\033[0m", first_space, bold));
			break;
		case 2:
			strcpy(text, string_union("\033[40m\033[1;34m", stringa, "\033[0m", first_space, bold));
			break;
		case 3:
			strcpy(text, string_union("\033[40m\033[31m", stringa, "\033[0m", first_space, bold));
			break;
		case 4:
			strcpy(text, string_union("\033[40m\033[1;31m", stringa, "\033[0m", first_space, bold));
			break;
		case 5:
			strcpy(text, string_union("\033[40m\033[1;37m", stringa, "\033[0m", first_space, bold));
			break;
		case 6:
			strcpy(text, string_union("\033[40m\033[35m", stringa, "\033[0m", first_space, bold));
			break;
		case 7:
			strcpy(text, string_union("\033[40m\033[36m", stringa, "\033[0m", first_space, bold));
			break;
		case 8:
			strcpy(text, string_union("\033[40m\033[1;36m", stringa, "\033[0m", first_space, bold));
			break;
		default:
			strcpy(text, string_union("", stringa, "", first_space, bold));
			break;
	}
	text[strlen(text)-1] = '\0';
	
	if(!error)
		printf("%s", text);		// Stampo la stringa concatenata solo se non serve a una print_error

	free(stringa);	// Dealloco lo spazio nell'heap
	return text;
}


void multiChoice(char *domanda, char choices[], int num, char *option)
{
	char *possib = (char *) malloc(2 * num * sizeof(char)); 	// Genera la stringa delle possibilità
	int i, j = 0;
	for(i = 0; i < num; i++) {
		possib[j++] = choices[i];
		possib[j++] = '/';
	}
	possib[j-1] = '\0'; 	// Per eliminare l'ultima '/'

	// Chiede la risposta
	printf("\033[40m\033[1;32m%s\033[0m [\033[40m\033[1;34m%s\033[0m]: ", domanda, possib); 	// Mostra la domanda
	
	char c[2];
	getInput(2, c, false);

	// Controlla se è un carattere valido
	for(i = 0; i < num; i++) {
		if(c[0] == choices[i]) {
			*option = c[0];
			return;
		}
	}
	
	*option = '#';	// number not found
	return;
	
}

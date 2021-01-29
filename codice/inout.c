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
char *getInputScanf(char *domanda, char *stringa, int length_max) {
	int length, i=0;
	char c;
	
	printf("%s", domanda);
	
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
	
	// Rilancio dei segnali pendenti
	if(signo)
		(void) raise(signo);
	
	return stringa;
}

// Per la gestione dei segnali
static void handler(int s) {
	signo = s;
}

void print_color(char *colorless, char *colore_scelto, char c, bool first_space, bool last_space, bool bold, bool blink) {
	char *stringa;
	char *list_color[] = {"orange", "blue", "light blue", "red", "light red", "white", "purple", "cyan", "light cyan", "yellow", "pink"};
	int i, length_list_color;
	
	// Controllo dei parametri
	if(strlen(colorless) == 0 && c == ' ') {
		print_error(NULL, "Error Parameters");
		return;
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
	length_list_color = 11; i = 0;		
	while(1) {
		if (i == length_list_color) {break;}
		if (strcmp(colore_scelto, list_color[i]) == 0) {break;}
		i++;
	}
	free(colore);
	
	// Stampa spazio
	if(first_space)
		printf("\n");
	
	// Stampa blink
	if(blink)
		printf("\e[1m\e[5m");
	
	// Stampa in grassetto
	if(bold)
		printf("\e[1m");
	
	
	// Stampa della stringa
	switch(i) {
	case 0:
		printf("\033[40m\033[1;32m");
		printf("%s", stringa);
		break;
	case 1:
		printf("\033[40m\033[34m");
		printf("%s", stringa);
		break;
	case 2:
		printf("\033[40m\033[1;34m");
		printf("%s", stringa);
		break;
	case 3:
		printf("\033[40m\033[31m");
		printf("%s", stringa);
		break;
	case 4:
		printf("\033[40m\033[1;31m");
		printf("%s", stringa);
		break;
	case 5:
		printf("\033[40m\033[1;37m");
		printf("%s", stringa);
		break;
	case 6:
		printf("\033[40m\033[35m");
		printf("%s", stringa);
		break;
	case 7:
		printf("\033[40m\033[36m");
		printf("%s", stringa);
		break;
	case 8:
		printf("\033[40m\033[1;36m");
		printf("%s", stringa);
		break;
	case 9:
		printf("\033[40m\033[1;33m");
		printf("%s", stringa);
		break;
	case 10:
		printf("\033[40m\033[1;35m");
		printf("%s", stringa);
		break;
	default:
		printf("%s", stringa);
		break;
	}
	
	// Delimiter color
	if(i<length_list_color)
		printf("\033[0m");	
	
	// Fine stampa in grassetto
	if(bold)
		printf("\e[22m");
	
	// Fine stampa blink
	if(blink)
		printf("\e[25m\e[22m");
	
	// Stampa spazio
	if(last_space)
		printf("\n");
	
	free(stringa);	// Deallocazione spazio nell'heap
	return;
}

bool yesOrNo(char *domanda, char yes, char no) {
	
	// I caratteri 'yes' e 'no' devono essere minuscoli
	yes = tolower(yes);
	no = tolower(no);

	// Richiesta della risposta
	while(true) {
		print_color(domanda, "white", ' ', false, false, true, false);	// Mostra la domanda
		printf(" [");
		print_color("", "light blue", yes, false, false, false, false);
		printf("/");
		print_color("", "light red", no, false, false, false, false);
		printf("]: ");

		//printf("\e[1m%s\e[22m [\033[40m\033[1;34m%c\033[0m/\033[40m\033[1;31m%c\033[0m]: ", domanda, yes, no);	// Mostra la domanda

		char c[2];
		getInput(2, c, false);
					
		// Controlla quale risposta è stata data
		if(c[0] == yes || c[0] == toupper(yes)) 
			return true;
		else if(c[0] == no || c[0] == toupper(no)) 
			return false;
	}
}

void multiChoice(char *domanda, char *choices[], int num, int *chosen_num, char *option)
{
	int i = 0, j = 0, lenght = 0;
	
	while(i<num)
		lenght += (int)strlen(choices[i++]);
	
	char *possib = (char *) malloc(lenght * num * sizeof(char *)); 	// Genera la stringa delle possibilità
	
	// Copia tutti i valori in un unica stringa
	for(i = 0; i < num; i++) {
		for(int z=0; z<(int)strlen(choices[i]); z++) {
			possib[j++] = choices[i][z];
		}	
		possib[j++] = '/';
	}
	possib[j-1] = '\0'; 	// Per eliminare l'ultima '/'

	// Chiede la risposta
	print_color(domanda, "white", ' ', true, false, true, false);	// Mostra la domanda
	printf(" [");
	print_color(possib, "light blue", ' ', false, false, false, false);
	printf("]: ");
	
	char c[3];
	strcpy(c, getInput(3, c, false));

	// Controlla se è un carattere valido
	for(i = 0; i < num; i++) {
		if(strcmp(c, choices[i]) == 0) {
			*chosen_num = i;	// Imposta l'indice all'interno della lista tramite dereferenziamento di puntatore
			return;
		}
	}
	
	*option = '#';	// numero non trovato
	return;
	
}


/*void multiChoice(char *domanda, char choices[], int num, char *option)
{
	char *possib = (char *) malloc(2 * num * sizeof(char)); 	// Genera la stringa delle possibilità
	int i, j = 0;
	for(i = 0; i < num; i++) {
		possib[j++] = choices[i];
		possib[j++] = '/';
	}
	possib[j-1] = '\0'; 	// Per eliminare l'ultima '/'

	// Chiede la risposta
	print_color(domanda, "white", ' ', true, false, true, false);	// Mostra la domanda
	printf(" [");
	print_color(possib, "light blue", ' ', false, false, false, false);
	printf("]: ");
	
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
	
}*/
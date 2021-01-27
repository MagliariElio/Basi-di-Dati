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
	printf("%s [\033[40m\033[1;34m%s\033[0m]: ", domanda, possib); 	// Mostra la domanda
	
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

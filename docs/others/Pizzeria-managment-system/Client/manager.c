#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <mysql/mysql.h>
#include "defines.h"


static void stampa_scontrino_tavolo(MYSQL *conn){
	MYSQL_STMT *prepared_stmt;
	MYSQL_BIND param[1];
	int tavolo;
	int status;
	bool first = true;
	
	if(!setup_prepared_stmt(&prepared_stmt, "call stampa_scontrino_tavolo(?)", conn)) {
		finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize stampa_scontrino_tavolo\n", false);
	}

	// Prepare parameters
	memset(param, 0, sizeof(param));
	printf("Inserire tavolo:\n");
	if(scanf("%d",&tavolo)<1){
		printf("Errore inserimento tavolo\n");
		flush_stdin();
		return;
	}
	flush_stdin();
	param[0].buffer_type = MYSQL_TYPE_LONG;
	param[0].buffer = &tavolo;
	param[0].buffer_length = sizeof(tavolo);
	
	
	if (mysql_stmt_bind_param(prepared_stmt, param) != 0) {
		finish_with_stmt_error(conn, prepared_stmt, "Could not bind parameters for stampa_scontrino_tavolo\n", true);
	}

	// Run procedure
	if (mysql_stmt_execute(prepared_stmt) != 0) {
		finish_with_stmt_error(conn, prepared_stmt, "Could not retrieve stampa_scontrino_tavolo\n", true);
		goto out;
	}

	// We have multiple result sets here!
	do {
		// Skip OUT variables (although they are not present in the procedure...)
		if(conn->server_status & SERVER_PS_OUT_PARAMS) {
			goto next;
		}

		if(first) {
			first = false;
			dump_result_set(conn, prepared_stmt, "Info scontrino:\n");
		} else {
			dump_result_set(conn, prepared_stmt, "Dettagli scontrino:\n");
		}

		// more results? -1 = no, >0 = error, 0 = yes (keep looking)
	    next:
		status = mysql_stmt_next_result(prepared_stmt);
		if (status > 0)
			finish_with_stmt_error(conn, prepared_stmt, "Unexpected condition", true);
		
	} while (status == 0);

    out:
	mysql_stmt_close(prepared_stmt);
}

static void visualizza_tavoli(MYSQL *conn){
	MYSQL_STMT *prepared_stmt;
	//Visualizzazione tavoli
	if(!setup_prepared_stmt(&prepared_stmt, "call visualizza_tavoli()", conn)) {
		finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize visualizza_tavoli statement\n", false);
	}

	// Run procedure
	if (mysql_stmt_execute(prepared_stmt) != 0) {
		finish_with_stmt_error(conn, prepared_stmt, "Could not retrieve visualizza_tavoli\n", true);
	}

	// Dump the result set
	dump_result_set(conn, prepared_stmt, "\n Lista tavoli");
	mysql_stmt_next_result(prepared_stmt);
	mysql_stmt_close(prepared_stmt);
}


static void registra_cliente(MYSQL *conn) {
	MYSQL_STMT *prepared_stmt;
	MYSQL_BIND param[4];
	MYSQL_BIND param1[2];
	char cf[16];
	char nome[45];
	char cognome[45];
	int commensali;
	int tavolo;

	//Registrazione cliente
	if(!setup_prepared_stmt(&prepared_stmt, "call registra_cliente(?,?,?,?)", conn)) {
		finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize registra_cliente statement\n", false);
	}

	// Prepare parameters
	memset(param, 0, sizeof(param));
	memset(cf,'\0', sizeof(cf));
	memset(nome,'\0', sizeof(nome));
	memset(cognome,'\0', sizeof(cognome));
	printf("Inserire CF cliente:\n");
	getInput(16,cf,false);
	printf("Inserire nome cliente:\n");
	getInput(45,nome,false);
	printf("Inserire cognome cliente:\n");
	getInput(45,cognome,false);
	printf("Inserire numero commensali:\n");
	if(scanf("%d",&commensali)<1){
		printf("Errore inserimento numero commensali\n");
		flush_stdin();
		return;
	}
	flush_stdin();
	param[0].buffer_type = MYSQL_TYPE_STRING;
	param[0].buffer = cf;
	param[0].buffer_length = sizeof(cf);

	param[1].buffer_type = MYSQL_TYPE_STRING;
	param[1].buffer = nome;
	param[1].buffer_length = sizeof(nome);

	param[2].buffer_type = MYSQL_TYPE_STRING;
	param[2].buffer = cognome;
	param[2].buffer_length = sizeof(cognome);

	param[3].buffer_type = MYSQL_TYPE_LONG;
	param[3].buffer = &commensali;
	param[3].buffer_length = sizeof(commensali);
	
	
	if (mysql_stmt_bind_param(prepared_stmt, param) != 0) {
		finish_with_stmt_error(conn, prepared_stmt, "Could not bind parameters for registra_cliente\n", true);
	}

	// Run procedure
	if (mysql_stmt_execute(prepared_stmt) != 0) {
		print_stmt_error(prepared_stmt, "Could not run register client\n");
	} else printf("Cliente registrato correttamente\n");

	mysql_stmt_close(prepared_stmt);

	visualizza_tavoli(conn);

	//Registrazione cliente
	if(!setup_prepared_stmt(&prepared_stmt, "call assegna_tavolo_a_cliente(?,?)", conn)) {
		finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize assegna_tavolo_a_cliente\n", false);
	}

	// Prepare parameters

	memset(param1, 0, sizeof(param1));
	printf("\n\nInserire tavolo da assegnare al cliente:\n");
	if(scanf("%d",&tavolo)<1){
		printf("Errore inserimento tavolo\n");
		flush_stdin();
		return;
	}

	flush_stdin();
	param1[1].buffer_type = MYSQL_TYPE_LONG;
	param1[1].buffer = &tavolo;
	param1[1].buffer_length = sizeof(tavolo);
	
	//For table assignment
	param1[0].buffer_type = MYSQL_TYPE_STRING;
	param1[0].buffer = cf;
	param1[0].buffer_length = sizeof(cf);

	if (mysql_stmt_bind_param(prepared_stmt, param1) != 0) {
		finish_with_stmt_error(conn, prepared_stmt, "Could not bind parameters for assegna_tavolo_a_cliente\n", true);
	}

	// Run procedure
	if (mysql_stmt_execute(prepared_stmt) != 0) {
		print_stmt_error(prepared_stmt, "Could not assign table\n");
	} else printf("Tavolo assegnato correttamente\n");

	mysql_stmt_close(prepared_stmt);
}

static void visualizza_entrate_giorno(MYSQL *conn){
	MYSQL_STMT *prepared_stmt;
	MYSQL_BIND param[2];
	MYSQL_TIME data;
	float entrate;

	if(!setup_prepared_stmt(&prepared_stmt, "call visualizza_entrate_giorno(?,?)", conn)) {
		finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize visualizza_entrate_giorno\n", false);
	}
	
	// Prepare parameters
	memset(param, 0, sizeof(param));
	
	printf("Inserire anno:\n");
	if(scanf("%4d",&data.year)<1){
		printf("Errore inserimento anno\n");
		flush_stdin();
		return;
	}
	flush_stdin();

	printf("Inserire mese:\n");
	if(scanf("%2d",&data.month)<1){
		printf("Errore inserimento mese\n");
		flush_stdin();
		return;
	}
	flush_stdin();

	printf("Inserire giorno:\n");
	if(scanf("%2d",&data.day)<1){
		printf("Errore inserimento giorno\n");
		flush_stdin();
		return;
	}
	flush_stdin();

	param[0].buffer_type = MYSQL_TYPE_DATE;
	param[0].buffer = (char *)&data;
	param[0].buffer_length = sizeof(data);
	
	param[1].buffer_type = MYSQL_TYPE_FLOAT; // OUT
	param[1].buffer = &entrate;
	param[1].buffer_length = sizeof(entrate);
	
	if (mysql_stmt_bind_param(prepared_stmt, param) != 0) {
		finish_with_stmt_error(conn, prepared_stmt, "Could not bind parameters for visualizza_entrate_giorno\n", true);
	}

	// Run procedure
	if (mysql_stmt_execute(prepared_stmt) != 0) {
		finish_with_stmt_error(conn, prepared_stmt, "Could not retrieve visualizza_entrate_giorno\n", true);
	}

	// Prepare output parameters
	memset(param, 0, sizeof(param));

	param[0].buffer_type = MYSQL_TYPE_FLOAT; // OUT
	param[0].buffer = &entrate;
	param[0].buffer_length = sizeof(entrate);
	
	if(mysql_stmt_bind_result(prepared_stmt, param)) {
		print_stmt_error(prepared_stmt, "Could not retrieve output parameter");
		return;
	}
	
	// Retrieve output parameter
	if(mysql_stmt_fetch(prepared_stmt)) {
		print_stmt_error(prepared_stmt, "Could not buffer results");
		return;
	}

	printf("Entrate del %02d/%02d/%4d: %f", data.day,data.month, data.year,entrate);
	mysql_stmt_close(prepared_stmt);
}

static void visualizza_entrate_mese(MYSQL *conn){
	MYSQL_STMT *prepared_stmt;
	MYSQL_BIND param[2];
	MYSQL_TIME data;
	data.day=01;
	float entrate=0;

	if(!setup_prepared_stmt(&prepared_stmt, "call visualizza_entrate_mese(?,?)", conn)) {
		finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize visualizza_entrate_mese\n", false);
	}

	// Prepare parameters
	memset(param, 0, sizeof(param));
	
	printf("Inserire anno:\n");
	if(scanf("%4d",&data.year)<1){
		printf("Errore inserimento anno\n");
		flush_stdin();
		return;
	}
	flush_stdin();
	
	printf("Inserire mese:\n");
	if(scanf("%2d",&data.month)<1){
		printf("Errore inserimento mese\n");
		flush_stdin();
		return;
	}
	flush_stdin();


	param[0].buffer_type = MYSQL_TYPE_DATE;
	param[0].buffer = (char *)&data;
	param[0].buffer_length = sizeof(data);

	param[1].buffer_type = MYSQL_TYPE_FLOAT;
	param[1].buffer = &entrate;
	param[1].buffer_length = sizeof(entrate);
	
	
	if (mysql_stmt_bind_param(prepared_stmt, param) != 0) {
		finish_with_stmt_error(conn, prepared_stmt, "Could not bind parameters for visualizza_entrate_mese\n", true);
	}

	// Run procedure
	if (mysql_stmt_execute(prepared_stmt) != 0) {
		finish_with_stmt_error(conn, prepared_stmt, "Could not retrieve visualizza_entrate_mese\n", true);
	}

	// Prepare output parameters
	memset(param, 0, sizeof(param));

	param[0].buffer_type = MYSQL_TYPE_FLOAT; // OUT
	param[0].buffer = &entrate;
	param[0].buffer_length = sizeof(entrate);
	
	if(mysql_stmt_bind_result(prepared_stmt, param)) {
		print_stmt_error(prepared_stmt, "Could not retrieve output parameter");
		return;
	}
	
	// Retrieve output parameter
	if(mysql_stmt_fetch(prepared_stmt)) {
		print_stmt_error(prepared_stmt, "Could not buffer results");
		return;
	}

	printf("Entrate del %02d/%4d: %f", data.month, data.year,entrate);
	mysql_stmt_close(prepared_stmt);
}

static void visualizza_menu_pizze(MYSQL *conn){
	MYSQL_STMT *prepared_stmt;

	//Pizza
	if(!setup_prepared_stmt(&prepared_stmt, "call visualizza_menu_pizze()", conn)) {
		finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize visualizza_menu_pizze statement\n", false);
	}
	
	// Run procedure
	if (mysql_stmt_execute(prepared_stmt) != 0) {
		finish_with_stmt_error(conn, prepared_stmt, "Could not retrieve visualizza_menu_pizze\n", true);
	}

	// Dump the result set
	dump_result_set(conn, prepared_stmt, "\n Menu' pizze");
	mysql_stmt_next_result(prepared_stmt);
	mysql_stmt_close(prepared_stmt);
}

static void visualizza_menu_ingredienti(MYSQL *conn){
	MYSQL_STMT *prepared_stmt;

	if(!setup_prepared_stmt(&prepared_stmt, "call visualizza_menu_ingredienti()", conn)) {
		finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize visualizza_menu_ingredienti statement\n", false);
	}
	
	// Run procedure
	if (mysql_stmt_execute(prepared_stmt) != 0) {
		finish_with_stmt_error(conn, prepared_stmt, "Could not retrieve visualizza_menu_ingredienti\n", true);
	}

	// Dump the result set
	dump_result_set(conn, prepared_stmt, "\n Menu' ingredienti");
	mysql_stmt_next_result(prepared_stmt);
	mysql_stmt_close(prepared_stmt);
}

static void visualizza_menu_bevande(MYSQL *conn){
	MYSQL_STMT *prepared_stmt;

	//Bevanda
	if(!setup_prepared_stmt(&prepared_stmt, "call visualizza_menu_bevande()", conn)) {
		finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize visualizza_menu_bevande statement\n", false);
	}
	
	// Run procedure
	if (mysql_stmt_execute(prepared_stmt) != 0) {
		finish_with_stmt_error(conn, prepared_stmt, "Could not retrieve visualizza_menu_bevande\n", true);
	}

	// Dump the result set
	dump_result_set(conn, prepared_stmt, "\n Menu' bevande");
	mysql_stmt_next_result(prepared_stmt);
	mysql_stmt_close(prepared_stmt);

}

static void aumenta_scorte_pizza(MYSQL *conn){
	MYSQL_STMT *prepared_stmt;
	MYSQL_BIND param[2];
	char pizza[45];
	int scorte;

	if(!setup_prepared_stmt(&prepared_stmt, "call aumenta_scorte_pizza(?,?)", conn)) {
		finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize aumenta_scorte_pizza\n", false);
	}

	// Prepare parameters
	memset(param, 0, sizeof(param));
	memset(pizza,'\0', sizeof(pizza));
	printf("Inserire pizza\n");
	getInput(45,pizza,false);
	printf("Inserire quantità:\n");
	if(scanf("%d",&scorte)<1){
		printf("Errore inserimento quantità\n");
		flush_stdin();
		return;
	}
	flush_stdin();
	param[0].buffer_type = MYSQL_TYPE_STRING;
	param[0].buffer = pizza;
	param[0].buffer_length = sizeof(pizza);

	param[1].buffer_type = MYSQL_TYPE_LONG;
	param[1].buffer = &scorte;
	param[1].buffer_length = sizeof(scorte);
	
	
	if (mysql_stmt_bind_param(prepared_stmt, param) != 0) {
		finish_with_stmt_error(conn, prepared_stmt, "Could not bind parameters for aumenta_scorte_pizza\n", true);
	}

	// Run procedure
	if (mysql_stmt_execute(prepared_stmt) != 0) {
		print_stmt_error(prepared_stmt, "Could not retrieve refill pizza\n");
	}else printf("Scorte aumentate correttamente\n");

	mysql_stmt_close(prepared_stmt);
}

static void aumenta_scorte_bevanda(MYSQL *conn){
	MYSQL_STMT *prepared_stmt;
	MYSQL_BIND param[2];
	char bevanda[45];
	int scorte;

	if(!setup_prepared_stmt(&prepared_stmt, "call aumenta_scorte_bevanda(?,?)", conn)) {
		finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize aumenta_scorte_bevanda\n", false);
	}

	// Prepare parameters
	memset(param, 0, sizeof(param));
	memset(bevanda,'\0', sizeof(bevanda));
	printf("Inserire bevanda\n");
	getInput(45,bevanda,false);
	printf("Inserire quantità:\n");
	if(scanf("%d",&scorte)<1){
		printf("Errore inserimento quantità\n");
		flush_stdin();
		return;
	}
	flush_stdin();
	param[0].buffer_type = MYSQL_TYPE_STRING;
	param[0].buffer = bevanda;
	param[0].buffer_length = sizeof(bevanda);

	param[1].buffer_type = MYSQL_TYPE_LONG;
	param[1].buffer = &scorte;
	param[1].buffer_length = sizeof(scorte);
	
	
	if (mysql_stmt_bind_param(prepared_stmt, param) != 0) {
		finish_with_stmt_error(conn, prepared_stmt, "Could not bind parameters for aumenta_scorte_bevanda\n", true);
	}

	// Run procedure
	if (mysql_stmt_execute(prepared_stmt) != 0) {
		print_stmt_error(prepared_stmt, "Could not retrieve refill bevanda\n");
	}else printf("Scorte aumentate correttamente\n");
	
	mysql_stmt_close(prepared_stmt);
}

static void aumenta_scorte_ingrediente(MYSQL *conn){
	MYSQL_STMT *prepared_stmt;
	MYSQL_BIND param[2];
	char ingrediente[45];
	int scorte;

	if(!setup_prepared_stmt(&prepared_stmt, "call aumenta_scorte_ingrediente(?,?)", conn)) {
		finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize aumenta_scorte_ingrediente\n", false);
	}

	// Prepare parameters
	memset(param, 0, sizeof(param));
	memset(ingrediente,'\0', sizeof(ingrediente));
	printf("Inserire ingrediente\n");
	getInput(45,ingrediente,false);
	printf("Inserire quantità:\n");
	if(scanf("%d",&scorte)<1){
		printf("Errore inserimento quantità\n");
		flush_stdin();
		return;
	}
	flush_stdin();
	param[0].buffer_type = MYSQL_TYPE_STRING;
	param[0].buffer = ingrediente;
	param[0].buffer_length = sizeof(ingrediente);

	param[1].buffer_type = MYSQL_TYPE_LONG;
	param[1].buffer = &scorte;
	param[1].buffer_length = sizeof(scorte);
	
	
	if (mysql_stmt_bind_param(prepared_stmt, param) != 0) {
		finish_with_stmt_error(conn, prepared_stmt, "Could not bind parameters for aumenta_scorte_ingrediente\n", true);
	}

	// Run procedure
	if (mysql_stmt_execute(prepared_stmt) != 0) {
		print_stmt_error(prepared_stmt, "Could not retrieve refill ingrediente\n");
	}else printf("Scorte aumentate correttamente\n");
	
	mysql_stmt_close(prepared_stmt);
}

static void aumenta_scorte_tutti_prodotti(MYSQL *conn){
	MYSQL_STMT *prepared_stmt;
	MYSQL_BIND param[1];
	int scorte;
	
	if(!setup_prepared_stmt(&prepared_stmt, "call aumenta_scorte_tutti_prodotti(?)", conn)) {
		finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize aumenta_scorte_tutti_prodotti\n", false);
	}

	// Prepare parameters
	memset(param, 0, sizeof(param));
	
	printf("Inserire quantità:\n");
	if(scanf("%d",&scorte)<1){
		printf("Errore inserimento quantità\n");
		flush_stdin();
		return;
	}
	flush_stdin();
	param[0].buffer_type = MYSQL_TYPE_LONG;
	param[0].buffer = &scorte;
	param[0].buffer_length = sizeof(scorte);
	
	
	if (mysql_stmt_bind_param(prepared_stmt, param) != 0) {
		finish_with_stmt_error(conn, prepared_stmt, "Could not bind parameters for aumenta_scorte_tutti_prodotti\n", true);
	}

	// Run procedure
	if (mysql_stmt_execute(prepared_stmt) != 0) {
		print_stmt_error(prepared_stmt, "Could not retrieve refill tutti_prodotti\n");
	}else printf("Scorte aumentate correttamente\n");
	
	mysql_stmt_close(prepared_stmt);
}

static void aumenta_scorte_prodotto(MYSQL *conn){
	char options[6] = {'1','2','3','4','5'};
	char op;

	while(true) {
		printf("\033[2J\033[H");
		printf("*** Cosa posso fare per te? ***\n\n");
		printf("1) Aumenta scorte pizza\n");
		printf("2) Aumenta scorte bevanda\n");
		printf("3) Aumenta scorte ingrediente\n");
		printf("4) Aumenta scorte di tutti i prodotti\n");
		printf("5) Quit\n");

		op = multiChoice("Seleziona un opzione", options, 5);

		switch(op) {

			case '1':
				aumenta_scorte_pizza(conn);
				break;
			case '2':
				aumenta_scorte_bevanda(conn);
				break;
			case '3':
				aumenta_scorte_ingrediente(conn);
				break;
			case '4':
				aumenta_scorte_tutti_prodotti(conn);
				break;	
			case '5':
				return;
				
			default:
				fprintf(stderr, "Invalid condition at %s:%d\n", __FILE__, __LINE__);
				abort();
		}

		getchar();
	}
}

static void aggiungi_pizza(MYSQL *conn){
	MYSQL_STMT *prepared_stmt;
	MYSQL_BIND param[2];
	char pizza[45];
	float prezzo;

	if(!setup_prepared_stmt(&prepared_stmt, "call aggiungi_pizza(?,?)", conn)) {
		finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize aggiungi_pizza\n", false);
	}

	// Prepare parameters
	memset(param, 0, sizeof(param));
	memset(pizza,'\0', sizeof(pizza));
	printf("Inserire pizza\n");
	getInput(45,pizza,false);

	printf("Inserire prezzo\n");
	if(scanf("%f",&prezzo)<1){
		printf("Inserimento prezzo fallito\n");
		flush_stdin();
		return;
	}
	flush_stdin();
	param[0].buffer_type = MYSQL_TYPE_STRING;
	param[0].buffer = pizza;
	param[0].buffer_length = sizeof(pizza);

	param[1].buffer_type = MYSQL_TYPE_FLOAT;
	param[1].buffer = &prezzo;
	param[1].buffer_length = sizeof(prezzo);

	
	if (mysql_stmt_bind_param(prepared_stmt, param) != 0) {
		finish_with_stmt_error(conn, prepared_stmt, "Could not bind parameters for aggiungi_pizza\n", true);
	}

	// Run procedure
	if (mysql_stmt_execute(prepared_stmt) != 0) {
		print_stmt_error(prepared_stmt, "Could not add pizza\n");
	}else printf("Pizza aggiunta correttamente\n");

	mysql_stmt_close(prepared_stmt);
}

static void aggiungi_bevanda(MYSQL *conn){
	MYSQL_STMT *prepared_stmt;
	MYSQL_BIND param[2];
	char bevanda[45];
	float prezzo;

	if(!setup_prepared_stmt(&prepared_stmt, "call aggiungi_bevanda(?,?)", conn)) {
		finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize aggiungi_bevanda\n", false);
	}

	// Prepare parameters
	memset(param, 0, sizeof(param));
	memset(bevanda,'\0', sizeof(bevanda));
	printf("Inserire bevanda\n");
	getInput(45,bevanda,false);

	printf("Inserire prezzo\n");
	if(scanf("%f",&prezzo)<1){
		printf("Inserimento prezzo fallito\n");
		flush_stdin();
		return;
	}
	flush_stdin();

	param[0].buffer_type = MYSQL_TYPE_STRING;
	param[0].buffer = bevanda;
	param[0].buffer_length = sizeof(bevanda);

	param[1].buffer_type = MYSQL_TYPE_FLOAT;
	param[1].buffer = &prezzo;
	param[1].buffer_length = sizeof(prezzo);
	
	if (mysql_stmt_bind_param(prepared_stmt, param) != 0) {
		finish_with_stmt_error(conn, prepared_stmt, "Could not bind parameters for aggiungi_bevanda\n", true);
	}

	// Run procedure
	if (mysql_stmt_execute(prepared_stmt) != 0) {
		print_stmt_error(prepared_stmt, "Could not add bevanda\n");
	}else printf("Bevanda aggiunta correttamente\n");

	mysql_stmt_close(prepared_stmt);
}

static void aggiungi_ingrediente(MYSQL *conn){
	MYSQL_STMT *prepared_stmt;
	MYSQL_BIND param[2];
	char ingrediente[45];
	float prezzo;

	if(!setup_prepared_stmt(&prepared_stmt, "call aggiungi_ingrediente(?,?)", conn)) {
		finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize aggiungi_ingrediente\n", false);
	}

	// Prepare parameters
	memset(param, 0, sizeof(param));
	memset(ingrediente,'\0', sizeof(ingrediente));
	printf("Inserire ingrediente\n");
	getInput(45,ingrediente,false);

	printf("Inserire prezzo\n");
	if(scanf("%f",&prezzo)<1){
		printf("Inserimento prezzo fallito\n");
		flush_stdin();
		return;
	}
	flush_stdin();
	param[0].buffer_type = MYSQL_TYPE_STRING;
	param[0].buffer = ingrediente;
	param[0].buffer_length = sizeof(ingrediente);

	param[1].buffer_type = MYSQL_TYPE_FLOAT;
	param[1].buffer = &prezzo;
	param[1].buffer_length = sizeof(prezzo);
	
	if (mysql_stmt_bind_param(prepared_stmt, param) != 0) {
		finish_with_stmt_error(conn, prepared_stmt, "Could not bind parameters for aggiungi_ingrediente\n", true);
	}

	// Run procedure
	if (mysql_stmt_execute(prepared_stmt) != 0) {
		print_stmt_error(prepared_stmt, "Could not add ingrediente\n");
	}else printf("Ingrediente aggiunta correttamente\n");

	mysql_stmt_close(prepared_stmt);
}

static void aggiungi_prodotto(MYSQL *conn){
	char options[5] = {'1','2','3','4'};
	char op;

	while(true) {
		printf("\033[2J\033[H");
		printf("*** Cosa posso fare per te? ***\n\n");
		printf("1) Aggiungi pizza\n");
		printf("2) Aggiungi bevanda\n");
		printf("3) Aggiungi ingrediente\n");
		printf("4) Quit\n");

		op = multiChoice("Seleziona un opzione", options, 4);

		switch(op) {

			case '1':
				aggiungi_pizza(conn);
				break;
			case '2':
				aggiungi_bevanda(conn);
				break;
			case '3':
				aggiungi_ingrediente(conn);
				break;	
			case '4':
				return;
				
			default:
				fprintf(stderr, "Invalid condition at %s:%d\n", __FILE__, __LINE__);
				abort();
		}

		getchar();
	}
}

static void rimuovi_pizza(MYSQL *conn){
	MYSQL_STMT *prepared_stmt;
	MYSQL_BIND param[1];
	char pizza[45];

	if(!setup_prepared_stmt(&prepared_stmt, "call rimuovi_pizza(?)", conn)) {
		finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize rimuovi_pizza\n", false);
	}

	// Prepare parameters
	memset(param, 0, sizeof(param));
	memset(pizza,'\0', sizeof(pizza));
	printf("Inserire pizza\n");
	getInput(45,pizza,false);

	param[0].buffer_type = MYSQL_TYPE_STRING;
	param[0].buffer = pizza;
	param[0].buffer_length = sizeof(pizza);
	
	if (mysql_stmt_bind_param(prepared_stmt, param) != 0) {
		finish_with_stmt_error(conn, prepared_stmt, "Could not bind parameters for rimuovi_pizza\n", true);
	}

	// Run procedure
	if (mysql_stmt_execute(prepared_stmt) != 0) {
		print_stmt_error(prepared_stmt, "Could not remove pizza\n");
	}else printf("Pizza rimossa correttamente\n");

	mysql_stmt_close(prepared_stmt);
}

static void rimuovi_bevanda(MYSQL *conn){
	MYSQL_STMT *prepared_stmt;
	MYSQL_BIND param[1];
	char bevanda[45];

	if(!setup_prepared_stmt(&prepared_stmt, "call rimuovi_bevanda(?)", conn)) {
		finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize rimuovi_bevanda\n", false);
	}

	// Prepare parameters
	memset(param, 0, sizeof(param));
	memset(bevanda,'\0', sizeof(bevanda));
	printf("Inserire bevanda\n");
	getInput(45,bevanda,false);

	param[0].buffer_type = MYSQL_TYPE_STRING;
	param[0].buffer = bevanda;
	param[0].buffer_length = sizeof(bevanda);
	
	if (mysql_stmt_bind_param(prepared_stmt, param) != 0) {
		finish_with_stmt_error(conn, prepared_stmt, "Could not bind parameters for rimuovi_bevanda\n", true);
	}

	// Run procedure
	if (mysql_stmt_execute(prepared_stmt) != 0) {
		print_stmt_error(prepared_stmt, "Could not remove bevanda\n");
	}else printf("Bevanda rimossa correttamente\n");

	mysql_stmt_close(prepared_stmt);
}

static void rimuovi_ingrediente(MYSQL *conn){
	MYSQL_STMT *prepared_stmt;
	MYSQL_BIND param[1];
	char ingrediente[45];

	if(!setup_prepared_stmt(&prepared_stmt, "call rimuovi_ingrediente(?)", conn)) {
		finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize rimuovi_ingrediente\n", false);
	}

	// Prepare parameters
	memset(param, 0, sizeof(param));
	memset(ingrediente,'\0', sizeof(ingrediente));
	printf("Inserire ingrediente\n");
	getInput(45,ingrediente,false);

	param[0].buffer_type = MYSQL_TYPE_STRING;
	param[0].buffer = ingrediente;
	param[0].buffer_length = sizeof(ingrediente);
	
	if (mysql_stmt_bind_param(prepared_stmt, param) != 0) {
		finish_with_stmt_error(conn, prepared_stmt, "Could not bind parameters for rimuovi_ingrediente\n", true);
	}

	// Run procedure
	if (mysql_stmt_execute(prepared_stmt) != 0) {
		print_stmt_error(prepared_stmt, "Could not remove ingrediente\n");
	}else printf("Ingrediente rimuovi correttamente\n");

	mysql_stmt_close(prepared_stmt);
}

static void rimuovi_prodotto(MYSQL *conn){
	char options[5] = {'1','2','3','4'};
	char op;

	while(true) {
		printf("\033[2J\033[H");
		printf("*** Cosa posso fare per te? ***\n\n");
		printf("1) Rimuovi pizza\n");
		printf("2) Rimuovi bevanda\n");
		printf("3) Rimuovi ingrediente\n");
		printf("4) Quit\n");

		op = multiChoice("Seleziona un opzione", options, 4);

		switch(op) {

			case '1':
				rimuovi_pizza(conn);
				break;
			case '2':
				rimuovi_bevanda(conn);
				break;
			case '3':
				rimuovi_ingrediente(conn);
				break;	
			case '4':
				return;
				
			default:
				fprintf(stderr, "Invalid condition at %s:%d\n", __FILE__, __LINE__);
				abort();
		}

		getchar();
	}
}

static void gestisci_prodotti(MYSQL *conn){
	char options[8] = {'1','2','3','4','5','6','7'};
	char op;

	while(true) {
		printf("\033[2J\033[H");
		printf("*** Cosa posso fare per te? ***\n\n");
		printf("1) Visualizza pizze\n");
		printf("2) Visualizza bevande\n");
		printf("3) Visualizza ingredienti\n");
		printf("4) Aumenta scorte prodotto\n");
		printf("5) Aggiungi prodotto\n");
		printf("6) Rimuovi prodotto\n");
		printf("7) Quit\n");

		op = multiChoice("Seleziona un opzione", options, 7);

		switch(op) {

			case '1':
				visualizza_menu_pizze(conn);
				break;
			case '2':
				visualizza_menu_bevande(conn);
				break;
			case '3':
				visualizza_menu_ingredienti(conn);
				break;
			case '4':
				aumenta_scorte_prodotto(conn);
				break;
			case '5':
				aggiungi_prodotto(conn);
				break;
			case '6':
				rimuovi_prodotto(conn);
				break;	
			case '7':
				return;
				
			default:
				fprintf(stderr, "Invalid condition at %s:%d\n", __FILE__, __LINE__);
				abort();
		}

		getchar();
	}
}

static void aggiungi_tavolo(MYSQL *conn){
	MYSQL_STMT *prepared_stmt;
	MYSQL_BIND param[2];
	int tavolo;
	int posti;

	if(!setup_prepared_stmt(&prepared_stmt, "call aggiungi_tavolo(?,?)", conn)) {
		finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize aggiungi_tavolo\n", false);
	}

	// Prepare parameters
	memset(param, 0, sizeof(param));
	
	printf("Inserire numero tavolo\n");
	if(scanf("%d",&tavolo)<1){
		printf("Errore nell'acquisire numero tavolo\n");
		flush_stdin();
		return;
	}
	flush_stdin();
	printf("Inserire numero posti tavolo\n");
	if(scanf("%d",&posti)<1){
		printf("Errore nell'acquisire numero posti tavolo\n");
		flush_stdin();
		return;
	}
	flush_stdin();
	param[0].buffer_type = MYSQL_TYPE_LONG;
	param[0].buffer = &tavolo;
	param[0].buffer_length = sizeof(tavolo);

	param[1].buffer_type = MYSQL_TYPE_LONG;
	param[1].buffer = &posti;
	param[1].buffer_length = sizeof(posti);
	
	
	if (mysql_stmt_bind_param(prepared_stmt, param) != 0) {
		finish_with_stmt_error(conn, prepared_stmt, "Could not bind parameters for aggiungi_tavolo\n", true);
	}

	// Run procedure
	if (mysql_stmt_execute(prepared_stmt) != 0) {
		print_stmt_error(prepared_stmt, "Could not add tavolo\n");
	}else printf("Tavolo aggiunto correttamente\n");

	mysql_stmt_close(prepared_stmt);
}

static void rimuovi_tavolo(MYSQL *conn){
	MYSQL_STMT *prepared_stmt;
	MYSQL_BIND param[1];
	int tavolo;
	
	if(!setup_prepared_stmt(&prepared_stmt, "call rimuovi_tavolo(?)", conn)) {
		finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize rimuovi_tavolo\n", false);
	}

	// Prepare parameters
	memset(param, 0, sizeof(param));
	
	printf("Inserire numero tavolo\n");
	if(scanf("%d",&tavolo)<1){
		printf("Errore nell'acquisire numero tavolo\n");
		flush_stdin();
		return;
	}
	flush_stdin();
	param[0].buffer_type = MYSQL_TYPE_LONG;
	param[0].buffer = &tavolo;
	param[0].buffer_length = sizeof(tavolo);
	
	if (mysql_stmt_bind_param(prepared_stmt, param) != 0) {
		finish_with_stmt_error(conn, prepared_stmt, "Could not bind parameters for rimuovi_tavolo\n", true);
	}

	// Run procedure
	if (mysql_stmt_execute(prepared_stmt) != 0) {
		print_stmt_error(prepared_stmt, "Could not remove tavolo\n");
	}else printf("Tavolo rimosso correttamente\n");
	
	mysql_stmt_close(prepared_stmt);
}

static void visualizza_camerieri(MYSQL *conn){
	MYSQL_STMT *prepared_stmt;
	//Camerieri
	if(!setup_prepared_stmt(&prepared_stmt, "call visualizza_camerieri()", conn)) {
		finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize visualizza_camerieri statement\n", false);
	}
	
	// Run procedure
	if (mysql_stmt_execute(prepared_stmt) != 0) {
		finish_with_stmt_error(conn, prepared_stmt, "Could not retrieve visualizza_camerieri\n", true);
	}

	// Dump the result set
	dump_result_set(conn, prepared_stmt, "\n Lista camerieri");
	mysql_stmt_next_result(prepared_stmt);
	mysql_stmt_close(prepared_stmt);
}

static void visualizza_assegnazioni_tavoli_camerieri(MYSQL *conn){
	MYSQL_STMT *prepared_stmt;
	//Camerieri
	if(!setup_prepared_stmt(&prepared_stmt, "call visualizza_assegnazioni_tavoli_a_camerieri()", conn)) {
		finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize visualizza_assegnazioni_tavoli_a_camerieri statement\n", false);
	}
	
	// Run procedure
	if (mysql_stmt_execute(prepared_stmt) != 0) {
		finish_with_stmt_error(conn, prepared_stmt, "Could not retrieve visualizza_assegnazioni_tavoli_a_camerieri\n", true);
	}

	// Dump the result set
	dump_result_set(conn, prepared_stmt, "\n Lista assegnazioni");
	mysql_stmt_next_result(prepared_stmt);
	mysql_stmt_close(prepared_stmt);
}

static void assegna_tavolo_a_cameriere(MYSQL *conn){
	MYSQL_STMT *prepared_stmt;
	MYSQL_BIND param[2];
	int tavolo;
	int cameriere;

	//Assegnazione
	if(!setup_prepared_stmt(&prepared_stmt, "call assegna_tavolo_a_cameriere(?,?)", conn)) {
		finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize assegna_tavolo_a_cameriere\n", false);
	}

	// Prepare parameters
	memset(param, 0, sizeof(param));
	
	printf("Inserire numero tavolo\n");
	if(scanf("%d",&tavolo)<1){
		printf("Errore nell'acquisire numero tavolo\n");
		flush_stdin();
		return;
	}
	flush_stdin();
	printf("Inserire matricola\n");
	if(scanf("%d",&cameriere)<1){
		printf("Errore nell'acquisire matricola\n");
		flush_stdin();
		return;
	}
	flush_stdin();
	param[0].buffer_type = MYSQL_TYPE_LONG;
	param[0].buffer = &cameriere;
	param[0].buffer_length = sizeof(cameriere);

	param[1].buffer_type = MYSQL_TYPE_LONG;
	param[1].buffer = &tavolo;
	param[1].buffer_length = sizeof(tavolo);

	
	if (mysql_stmt_bind_param(prepared_stmt, param) != 0) {
		finish_with_stmt_error(conn, prepared_stmt, "Could not bind parameters for assegna_tavolo_a_cameriere\n", true);
	}

	// Run procedure
	if (mysql_stmt_execute(prepared_stmt) != 0) {
		print_stmt_error(prepared_stmt, "Could not assign table\n");
	}else printf("Tavolo assegnato correttamente\n");

	mysql_stmt_close(prepared_stmt);
}

static void rimuovi_tavolo_a_cameriere(MYSQL *conn){
	MYSQL_STMT *prepared_stmt;
	MYSQL_BIND param[2];
	int tavolo;
	int cameriere;

	//Rimozione assegnazione
	if(!setup_prepared_stmt(&prepared_stmt, "call rimuovi_assegnazione_tavolo(?,?)", conn)) {
		finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize rimuovi_assegnazione_tavolo\n", false);
	}

	// Prepare parameters
	memset(param, 0, sizeof(param));
	
	printf("Inserire numero tavolo\n");
	if(scanf("%d",&tavolo)<1){
		printf("Errore nell'acquisire numero tavolo\n");
		flush_stdin();
		return;
	}
	flush_stdin();
	printf("Inserire matricola\n");
	if(scanf("%d",&cameriere)<1){
		printf("Errore nell'acquisire matricola\n");
		flush_stdin();
		return;
	}
	flush_stdin();
	param[0].buffer_type = MYSQL_TYPE_LONG;
	param[0].buffer = &cameriere;
	param[0].buffer_length = sizeof(cameriere);

	param[1].buffer_type = MYSQL_TYPE_LONG;
	param[1].buffer = &tavolo;
	param[1].buffer_length = sizeof(tavolo);

	
	if (mysql_stmt_bind_param(prepared_stmt, param) != 0) {
		finish_with_stmt_error(conn, prepared_stmt, "Could not bind parameters for rimuovi_assegnazione_tavolo\n", true);
	}

	// Run procedure
	if (mysql_stmt_execute(prepared_stmt) != 0) {
		print_stmt_error(prepared_stmt, "Could not remove table assignment\n");
	}else printf("Assegnazione tavolo rimossa correttamente\n");

	mysql_stmt_close(prepared_stmt);
}

static void gestisci_tavoli(MYSQL *conn){
	char options[9] = {'1','2','3','4','5','6','7','8'};
	char op;

	while(true) {
		printf("\033[2J\033[H");
		printf("*** Cosa posso fare per te? ***\n\n");
		printf("1) Visualizza tavoli\n");
		printf("2) Aggiungi tavolo\n");
		printf("3) Rimuovi tavolo\n");
		printf("4) Assegna tavolo a cameriere\n");
		printf("5) Rimuovi tavolo a cameriere\n");
		printf("6) Visualizza camerieri\n");
		printf("7) Visualizza assegnazioni tavoli\n");
		printf("8) Quit\n");

		op = multiChoice("Seleziona un opzione", options, 8);

		switch(op) {
			case '1':
				visualizza_tavoli(conn);
				break;
			case '2':
				aggiungi_tavolo(conn);
				break;
			case '3':
				rimuovi_tavolo(conn);
				break;
			case '4':
				assegna_tavolo_a_cameriere(conn);
				break;
			case '5':
				rimuovi_tavolo_a_cameriere(conn);
				break;
			case '6':
				visualizza_camerieri(conn);
				break;
			case '7':
				visualizza_assegnazioni_tavoli_camerieri(conn);
				break;
			case '8':
				return;
				
			default:
				fprintf(stderr, "Invalid condition at %s:%d\n", __FILE__, __LINE__);
				abort();
		}

		getchar();
	}
}

static int choose_day(){
	char options[9] = {'1','2','3','4','5','6','7','8'};
	char op;

	while(true) {
		printf("\033[2J\033[H");
		printf("*** Selezionare un giorno ***\n\n");
		printf("1) Lunedi'\n");
		printf("2) Martedi'\n");
		printf("3) Mercoledi'\n");
		printf("4) Giovedi'\n");
		printf("5) Venerdi'\n");
		printf("6) Sabato\n");
		printf("7) Domenica\n");
		printf("8) Quit\n");

		op = multiChoice("Seleziona un opzione", options, 8);

		switch(op) {

			case '1':
				return 2;
			case '2':
				return 3;
			case '3':
				return 4;
			case '4':
				return 5;
			case '5':
				return 6;
			case '6':
				return 7;
			case '7':
				return 1;
			case '8':
				return -1;
				
			default:
				fprintf(stderr, "Invalid condition at %s:%d\n", __FILE__, __LINE__);
				abort();
		}

		getchar();
	}
}

static void visualizza_turni(MYSQL *conn){
	MYSQL_STMT *prepared_stmt;
	//Visualizza turni
	if(!setup_prepared_stmt(&prepared_stmt, "call visualizza_turni()", conn)) {
		finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize visualizza_turni\n", false);
	}

	// Run procedure
	if (mysql_stmt_execute(prepared_stmt) != 0) {
		finish_with_stmt_error(conn, prepared_stmt, "Could not retrieve visualizza_turni\n", true);
	}

	// Dump the result set
	dump_result_set(conn, prepared_stmt, "\nTurni:");
	mysql_stmt_next_result(prepared_stmt);
	mysql_stmt_close(prepared_stmt);
}

static void visualizza_impiegati(MYSQL *conn){
	MYSQL_STMT *prepared_stmt;
	//Visualizza impiegati
	if(!setup_prepared_stmt(&prepared_stmt, "call visualizza_impiegati()", conn)) {
		finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize visualizza_impiegati\n", false);
	}

	// Run procedure
	if (mysql_stmt_execute(prepared_stmt) != 0) {
		finish_with_stmt_error(conn, prepared_stmt, "Could not retrieve visualizza_impiegati\n", true);
	}

	// Dump the result set
	dump_result_set(conn, prepared_stmt, "\nImpiegati:");
	mysql_stmt_next_result(prepared_stmt);
	mysql_stmt_close(prepared_stmt);
}

static void assegna_turno_a_impiegato(MYSQL *conn){
	MYSQL_STMT *prepared_stmt;
	MYSQL_BIND param[4];
	int impiegato;
	int giorno;
	MYSQL_TIME ora_inizio;
	MYSQL_TIME ora_fine;
	ora_inizio.second=0;
	ora_fine.second=0;

	//Assegna turno
	if(!setup_prepared_stmt(&prepared_stmt, "call assegna_turno_a_impiegato(?,?,?,?)", conn)) {
		finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize assegna_turno_a_impiegato\n", false);
	}

	// Prepare parameters
	memset(param, 0, sizeof(param));
	memset(&ora_inizio,0,sizeof(ora_inizio));
	memset(&ora_fine,0,sizeof(ora_fine));

	printf("Inserisci matricola impiegato\n");
	if(scanf("%d",&impiegato)<1){
		printf("Errore acquisizione impiegato\n");
		flush_stdin();
		return;
	}
	flush_stdin();

	printf("Inserire ora inizio turno:\n");
	if(scanf("%2d",&ora_inizio.hour)<1){
		printf("Errore inserimento ora inizio turno\n");
		flush_stdin();
		return;
	}
	flush_stdin();

	printf("Inserire minuto inizio turno:\n");
	if(scanf("%2d",&ora_inizio.minute)<1){
		printf("Errore inserimento minuto inizio turno\n");
		flush_stdin();
		return;
	}
	flush_stdin();

	printf("Inserire ora fine turno:\n");
	if(scanf("%2d",&ora_fine.hour)<1){
		printf("Errore inserimento ora fine turno\n");
		flush_stdin();
		return;
	}
	flush_stdin();

	printf("Inserire minuto fine turno:\n");
	if(scanf("%2d",&ora_fine.minute)<1){
		printf("Errore inserimento minuto fine turno\n");
		flush_stdin();
		return;
	}
	flush_stdin();

	if((giorno=choose_day())==-1){
		printf("Non e' stato selezionato un giorno\n");
		return;
	}


	param[0].buffer_type = MYSQL_TYPE_LONG;
	param[0].buffer = &impiegato;
	param[0].buffer_length = sizeof(impiegato);

	param[1].buffer_type = MYSQL_TYPE_TIME;
	param[1].buffer = &ora_inizio;
	param[1].buffer_length = sizeof(ora_inizio);

	param[2].buffer_type = MYSQL_TYPE_TIME;
	param[2].buffer = &ora_fine;
	param[2].buffer_length = sizeof(ora_fine);

	param[3].buffer_type = MYSQL_TYPE_LONG;
	param[3].buffer = &giorno;
	param[3].buffer_length = sizeof(giorno);
	
	
	if (mysql_stmt_bind_param(prepared_stmt, param) != 0) {
		finish_with_stmt_error(conn, prepared_stmt, "Could not bind parameters for assegna_turno_a_impiegato\n", true);
	}

	// Run procedure
	if (mysql_stmt_execute(prepared_stmt) != 0) {
		print_stmt_error(prepared_stmt, "Could not assign workshift to employee\n");
	}else printf("Turno assegnato correttamente\n");
	mysql_stmt_close(prepared_stmt);
}

static void assegna_turno_a_tavolo(MYSQL *conn){
	MYSQL_STMT *prepared_stmt;
	MYSQL_BIND param[4];
	int tavolo;
	int giorno;
	MYSQL_TIME ora_inizio;
	MYSQL_TIME ora_fine;
	ora_inizio.second=0;
	ora_fine.second=0;

	if(!setup_prepared_stmt(&prepared_stmt, "call assegna_turno_a_tavolo(?,?,?,?)", conn)) {
		finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize assegna_turno_a_tavolo\n", false);
	}

	// Prepare parameters
	memset(param, 0, sizeof(param));
	memset(&ora_inizio,0,sizeof(ora_inizio));
	memset(&ora_fine,0,sizeof(ora_fine));

	printf("Inserisci numero tavolo\n");
	if(scanf("%d",&tavolo)<1){
		printf("Errore acquisizione numero tavolo\n");
		flush_stdin();
		return;
	}
	flush_stdin();

	printf("Inserire ora inizio turno:\n");
	if(scanf("%2d",&ora_inizio.hour)<1){
		printf("Errore inserimento ora inizio turno\n");
		flush_stdin();
		return;
	}
	flush_stdin();

	printf("Inserire minuto inizio turno:\n");
	if(scanf("%2d",&ora_inizio.minute)<1){
		printf("Errore inserimento minuto inizio turno\n");
		flush_stdin();
		return;
	}
	flush_stdin();

	printf("Inserire ora fine turno:\n");
	if(scanf("%2d",&ora_fine.hour)<1){
		printf("Errore inserimento ora fine turno\n");
		flush_stdin();
		return;
	}
	flush_stdin();

	printf("Inserire minuto fine turno:\n");
	if(scanf("%2d",&ora_fine.minute)<1){
		printf("Errore inserimento minuto fine turno\n");
		flush_stdin();
		return;
	}
	flush_stdin();

	if((giorno=choose_day())==-1){
		printf("Non e' stato selezionato un giorno\n");
		return;
	}


	param[0].buffer_type = MYSQL_TYPE_LONG;
	param[0].buffer = &tavolo;
	param[0].buffer_length = sizeof(tavolo);

	param[1].buffer_type = MYSQL_TYPE_TIME;
	param[1].buffer = &ora_inizio;
	param[1].buffer_length = sizeof(ora_inizio);

	param[2].buffer_type = MYSQL_TYPE_TIME;
	param[2].buffer = &ora_fine;
	param[2].buffer_length = sizeof(ora_fine);

	param[3].buffer_type = MYSQL_TYPE_LONG;
	param[3].buffer = &giorno;
	param[3].buffer_length = sizeof(giorno);
	
	
	if (mysql_stmt_bind_param(prepared_stmt, param) != 0) {
		finish_with_stmt_error(conn, prepared_stmt, "Could not bind parameters for assegna_turno_a_tavolo\n", true);
	}

	// Run procedure
	if (mysql_stmt_execute(prepared_stmt) != 0) {
		print_stmt_error(prepared_stmt, "Could not assign workshift to table\n");
	}else printf("Turno assegnato correttamente\n");
	mysql_stmt_close(prepared_stmt);
}

static void visualizza_turni_impiegati(MYSQL *conn){
	MYSQL_STMT *prepared_stmt;

	//Visualizza turni
	if(!setup_prepared_stmt(&prepared_stmt, "call visualizza_turni_impiegati()", conn)) {
		finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize visualizza_turni_impiegati\n", false);
	}

	// Run procedure
	if (mysql_stmt_execute(prepared_stmt) != 0) {
		finish_with_stmt_error(conn, prepared_stmt, "Could not retrieve visualizza_turni_impiegati\n", true);
	}

	// Dump the result set
	dump_result_set(conn, prepared_stmt, "\nTurni impiegati:");
	mysql_stmt_next_result(prepared_stmt);
	mysql_stmt_close(prepared_stmt);	
}

static void rimuovi_turno_a_impiegato(MYSQL *conn){
	MYSQL_STMT *prepared_stmt;
	MYSQL_BIND param[4];
	int impiegato;
	int giorno;
	MYSQL_TIME ora_inizio;
	MYSQL_TIME ora_fine;
	ora_inizio.second=0;
	ora_fine.second=0;

	if(!setup_prepared_stmt(&prepared_stmt, "call rimuovi_turno_impiegato(?,?,?,?)", conn)) {
		finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize rimuovi_turno_impiegato\n", false);
	}

	// Prepare parameters
	memset(param, 0, sizeof(param));
	memset(&ora_inizio,0,sizeof(ora_inizio));
	memset(&ora_fine,0,sizeof(ora_fine));

	printf("Inserisci matricola impiegato\n");
	if(scanf("%d",&impiegato)<1){
		printf("Errore acquisizione matricola impiegato\n");
		flush_stdin();
		return;
	}
	flush_stdin();

	printf("Inserire ora inizio turno:\n");
	if(scanf("%2d",&ora_inizio.hour)<1){
		printf("Errore inserimento ora inizio turno\n");
		flush_stdin();
		return;
	}
	flush_stdin();

	printf("Inserire minuto inizio turno:\n");
	if(scanf("%2d",&ora_inizio.minute)<1){
		printf("Errore inserimento minuto inizio turno\n");
		flush_stdin();
		return;
	}
	flush_stdin();

	printf("Inserire ora fine turno:\n");
	if(scanf("%2d",&ora_fine.hour)<1){
		printf("Errore inserimento ora fine turno\n");
		flush_stdin();
		return;
	}
	flush_stdin();

	printf("Inserire minuto fine turno:\n");
	if(scanf("%2d",&ora_fine.minute)<1){
		printf("Errore inserimento minuto fine turno\n");
		flush_stdin();
		return;
	}
	flush_stdin();

	if((giorno=choose_day())==-1){
		printf("Non e' stato selezionato un giorno\n");
		return;
	}


	param[0].buffer_type = MYSQL_TYPE_LONG;
	param[0].buffer = &impiegato;
	param[0].buffer_length = sizeof(impiegato);

	param[1].buffer_type = MYSQL_TYPE_TIME;
	param[1].buffer = &ora_inizio;
	param[1].buffer_length = sizeof(ora_inizio);

	param[2].buffer_type = MYSQL_TYPE_TIME;
	param[2].buffer = &ora_fine;
	param[2].buffer_length = sizeof(ora_fine);

	param[3].buffer_type = MYSQL_TYPE_LONG;
	param[3].buffer = &giorno;
	param[3].buffer_length = sizeof(giorno);
	
	
	if (mysql_stmt_bind_param(prepared_stmt, param) != 0) {
		finish_with_stmt_error(conn, prepared_stmt, "Could not bind parameters for rimuovi_turno_impiegato\n", true);
	}

	// Run procedure
	if (mysql_stmt_execute(prepared_stmt) != 0) {
		print_stmt_error(prepared_stmt, "Could not remove employee's workshift\n");
	}else printf("Turno rimosso correttamente\n");
	mysql_stmt_close(prepared_stmt);
}

static void visualizza_turni_tavoli(MYSQL *conn){
	MYSQL_STMT *prepared_stmt;

	//Visualizza turni
	if(!setup_prepared_stmt(&prepared_stmt, "call visualizza_turni_tavoli()", conn)) {
		finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize visualizza_turni_tavoli\n", false);
	}

	// Run procedure
	if (mysql_stmt_execute(prepared_stmt) != 0) {
		finish_with_stmt_error(conn, prepared_stmt, "Could not retrieve visualizza_turni_tavoli\n", true);
	}

	// Dump the result set
	dump_result_set(conn, prepared_stmt, "\nTurni tavoli:");
	mysql_stmt_next_result(prepared_stmt);
	mysql_stmt_close(prepared_stmt);	
}

static void rimuovi_turno_a_tavolo(MYSQL *conn){
	MYSQL_STMT *prepared_stmt;
	MYSQL_BIND param[4];
	int tavolo;
	int giorno;
	MYSQL_TIME ora_inizio;
	MYSQL_TIME ora_fine;
	ora_inizio.second=0;
	ora_fine.second=0;

	if(!setup_prepared_stmt(&prepared_stmt, "call rimuovi_turno_tavolo(?,?,?,?)", conn)) {
		finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize rimuovi_turno_tavolo\n", false);
	}

	// Prepare parameters
	memset(param, 0, sizeof(param));
	memset(&ora_inizio,0,sizeof(ora_inizio));
	memset(&ora_fine,0,sizeof(ora_fine));

	printf("Inserisci numero tavolo\n");
	if(scanf("%d",&tavolo)<1){
		printf("Errore acquisizione numero tavolo\n");
		flush_stdin();
		return;
	}
	flush_stdin();

	printf("Inserire ora inizio turno:\n");
	if(scanf("%2d",&ora_inizio.hour)<1){
		printf("Errore inserimento ora inizio turno\n");
		flush_stdin();
		return;
	}
	flush_stdin();

	printf("Inserire minuto inizio turno:\n");
	if(scanf("%2d",&ora_inizio.minute)<1){
		printf("Errore inserimento minuto inizio turno\n");
		flush_stdin();
		return;
	}
	flush_stdin();

	printf("Inserire ora fine turno:\n");
	if(scanf("%2d",&ora_fine.hour)<1){
		printf("Errore inserimento ora fine turno\n");
		flush_stdin();
		return;
	}
	flush_stdin();

	printf("Inserire minuto fine turno:\n");
	if(scanf("%2d",&ora_fine.minute)<1){
		printf("Errore inserimento minuto fine turno\n");
		flush_stdin();
		return;
	}
	flush_stdin();

	if((giorno=choose_day())==-1){
		printf("Non e' stato selezionato un giorno\n");
		return;
	}


	param[0].buffer_type = MYSQL_TYPE_LONG;
	param[0].buffer = &tavolo;
	param[0].buffer_length = sizeof(tavolo);

	param[1].buffer_type = MYSQL_TYPE_TIME;
	param[1].buffer = &ora_inizio;
	param[1].buffer_length = sizeof(ora_inizio);

	param[2].buffer_type = MYSQL_TYPE_TIME;
	param[2].buffer = &ora_fine;
	param[2].buffer_length = sizeof(ora_fine);

	param[3].buffer_type = MYSQL_TYPE_LONG;
	param[3].buffer = &giorno;
	param[3].buffer_length = sizeof(giorno);
	
	
	if (mysql_stmt_bind_param(prepared_stmt, param) != 0) {
		finish_with_stmt_error(conn, prepared_stmt, "Could not bind parameters for rimuovi_turno_tavolo\n", true);
	}

	// Run procedure
	if (mysql_stmt_execute(prepared_stmt) != 0) {
		print_stmt_error(prepared_stmt, "Could not remove table's workshift\n");
	}else printf("Turno rimosso correttamente\n");
	mysql_stmt_close(prepared_stmt);
}

static void aggiungi_turno(MYSQL *conn){
	MYSQL_STMT *prepared_stmt;
	MYSQL_BIND param[3];
	int giorno;
	MYSQL_TIME ora_inizio;
	MYSQL_TIME ora_fine;
	ora_inizio.second=0;
	ora_fine.second=0;

	if(!setup_prepared_stmt(&prepared_stmt, "call aggiungi_turno(?,?,?)", conn)) {
		finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize aggiungi_turno\n", false);
	}

	// Prepare parameters
	memset(param, 0, sizeof(param));
	memset(&ora_inizio,0,sizeof(ora_inizio));
	memset(&ora_fine,0,sizeof(ora_fine));

	printf("Inserire ora inizio turno:\n");
	if(scanf("%02d",&ora_inizio.hour)<1){
		printf("Errore inserimento ora inizio turno\n");
		flush_stdin();
		return;
	}	
	flush_stdin();
	
	printf("Inserire minuto inizio turno:\n");
	if(scanf("%02d",&ora_inizio.minute)<1){
		printf("Errore inserimento minuto inizio turno\n");
		flush_stdin();
		return;
	}
	flush_stdin();
	
	printf("Inserire ora fine turno:\n");
	if(scanf("%02d",&ora_fine.hour)<1){
		printf("Errore inserimento ora fine turno\n");
		flush_stdin();
		return;
	}
	flush_stdin();

	printf("Inserire minuto fine turno:\n");
	if(scanf("%02d",&ora_fine.minute)<1){
		printf("Errore inserimento minuto fine turno\n");
		flush_stdin();
		return;
	}
	flush_stdin();

	if((giorno=choose_day())==-1){
		printf("Non e' stato selezionato un giorno\n");
		return;
	}


	param[0].buffer_type = MYSQL_TYPE_TIME;
	param[0].buffer = (char *)&ora_inizio;
	param[0].buffer_length = sizeof(ora_inizio);

	param[1].buffer_type = MYSQL_TYPE_TIME;
	param[1].buffer = &ora_fine;
	param[1].buffer_length = sizeof(ora_fine);

	param[2].buffer_type = MYSQL_TYPE_LONG;
	param[2].buffer = &giorno;
	param[2].buffer_length = sizeof(giorno);

	if (mysql_stmt_bind_param(prepared_stmt, param) != 0) {
		finish_with_stmt_error(conn, prepared_stmt, "Could not bind parameters for aggiungi_turno\n", true);
	}

	// Run procedure
	if (mysql_stmt_execute(prepared_stmt) != 0) {
		print_stmt_error(prepared_stmt, "Could not add workshift\n");
	}else printf("Turno aggiunto correttamente\n");
	mysql_stmt_close(prepared_stmt);
}

static void rimuovi_turno(MYSQL *conn){
	MYSQL_STMT *prepared_stmt;
	MYSQL_BIND param[3];
	int giorno;
	MYSQL_TIME ora_inizio;
	MYSQL_TIME ora_fine;
	ora_inizio.second=0;
	ora_fine.second=0;

	//rimuovi turno
	if(!setup_prepared_stmt(&prepared_stmt, "call rimuovi_turno(?,?,?)", conn)) {
		finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize rimuovi_turno\n", false);
	}

	// Prepare parameters
	memset(param, 0, sizeof(param));
	memset(&ora_inizio,0,sizeof(ora_inizio));
	memset(&ora_fine,0,sizeof(ora_fine));

	printf("Inserire ora inizio turno:\n");
	if(scanf("%2d",&ora_inizio.hour)<1){
		printf("Errore inserimento ora inizio turno\n");
		flush_stdin();
		return;
	}
	flush_stdin();
	
	printf("Inserire minuto inizio turno:\n");
	if(scanf("%2d",&ora_inizio.minute)<1){
		printf("Errore inserimento minuto inizio turno\n");
		flush_stdin();
		return;
	}
	flush_stdin();
	
	printf("Inserire ora fine turno:\n");
	if(scanf("%2d",&ora_fine.hour)<1){
		printf("Errore inserimento ora fine turno\n");
		flush_stdin();
		return;
	}
	flush_stdin();

	printf("Inserire minuto fine turno:\n");
	if(scanf("%2d",&ora_fine.minute)<1){
		printf("Errore inserimento minuto fine turno\n");
		flush_stdin();
		return;
	}
	flush_stdin();
	
	if((giorno=choose_day())==-1){
		printf("Non e' stato selezionato un giorno\n");
		return;
	}


	param[0].buffer_type = MYSQL_TYPE_TIME;
	param[0].buffer = (char *)&ora_inizio;
	param[0].buffer_length = sizeof(ora_inizio);

	param[1].buffer_type = MYSQL_TYPE_TIME;
	param[1].buffer = (char *)&ora_fine;
	param[1].buffer_length = sizeof(ora_fine);

	param[2].buffer_type = MYSQL_TYPE_LONG;
	param[2].buffer = &giorno;
	param[2].buffer_length = sizeof(giorno);
	
	
	if (mysql_stmt_bind_param(prepared_stmt, param) != 0) {
		finish_with_stmt_error(conn, prepared_stmt, "Could not bind parameters for rimuovi_turno\n", true);
	}

	// Run procedure
	if (mysql_stmt_execute(prepared_stmt) != 0) {
		print_stmt_error(prepared_stmt, "Could not remove workshift\n");
	}else printf("Turno rimosso correttamente\n");
	mysql_stmt_close(prepared_stmt);
}

static void gestisci_turni_tavoli(MYSQL *conn){
	char options[6] = {'1','2','3','4','5'};
	char op;

	while(true) {
		printf("\033[2J\033[H");
		printf("*** Cosa posso fare per te? ***\n\n");
		printf("1) Visualizza turni tavoli\n");
		printf("2) Visualizza turni\n");
		printf("3) Assegna turno a tavolo\n");
		printf("4) Rimuovi turno a tavolo\n");
		printf("5) Quit\n");

		op = multiChoice("Seleziona un opzione", options, 5);

		switch(op) {

			case '1':
				visualizza_turni_tavoli(conn);
				break;
			case '2':
				visualizza_turni(conn);
				break;
			case '3':
				assegna_turno_a_tavolo(conn);
				break;
			case '4':
				rimuovi_turno_a_tavolo(conn);
				break;
			case '5':
				return;
				
			default:
				fprintf(stderr, "Invalid condition at %s:%d\n", __FILE__, __LINE__);
				abort();
		}

		getchar();
	}
}

static void gestisci_turni_impiegati(MYSQL *conn){
	char options[6] = {'1','2','3','4','5'};
	char op;

	while(true) {
		printf("\033[2J\033[H");
		printf("*** Cosa posso fare per te? ***\n\n");
		printf("1) Visualizza turni impiegati\n");
		printf("2) Visualizza turni\n");
		printf("3) Assegna turno a impiegato\n");
		printf("4) Rimuovi turno a impiegato\n");
		printf("5) Quit\n");

		op = multiChoice("Seleziona un opzione", options, 5);

		switch(op) {

			case '1':
				visualizza_turni_impiegati(conn);
				break;
			case '2':
				visualizza_turni(conn);
				break;
			case '3':
				assegna_turno_a_impiegato(conn);
				break;
			case '4':
				rimuovi_turno_a_impiegato(conn);
				break;
			case '5':
				return;
				
			default:
				fprintf(stderr, "Invalid condition at %s:%d\n", __FILE__, __LINE__);
				abort();
		}

		getchar();
	}
}

static void gestisci_turni(MYSQL *conn){
	char options[7] = {'1','2','3','4','5','6'};
	char op;

	while(true) {
		printf("\033[2J\033[H");
		printf("*** Cosa posso fare per te? ***\n\n");
		printf("1) Gestisci turni impiegati\n");
		printf("2) Gestisci turni tavoli\n");
		printf("3) Visualizza turni\n");
		printf("4) Aggiungi turno\n");
		printf("5) Rimuovi turno\n");
		printf("6) Quit\n");

		op = multiChoice("Seleziona un opzione", options, 6);

		switch(op) {

			case '1':
				gestisci_turni_impiegati(conn);
				break;
			case '2':
				gestisci_turni_tavoli(conn);
				break;
			case '3':
				visualizza_turni(conn);
				break;
			case '4':
				aggiungi_turno(conn);
				break;
			case '5':
				rimuovi_turno(conn);
				break;
			case '6':
				return;
				
			default:
				fprintf(stderr, "Invalid condition at %s:%d\n", __FILE__, __LINE__);
				abort();
		}

		getchar();
	}
}

static int choose_role(){
	char options[6] = {'1','2','3','4','5'};
	char op;

	while(true) {
		printf("\033[2J\033[H");
		printf("*** Selezionare un ruolo ***\n\n");
		printf("1) Manager\n");
		printf("2) Cameriere\n");
		printf("3) Pizzaiolo\n");
		printf("4) Barman\n");
		printf("5) Quit\n");

		op = multiChoice("Seleziona un opzione", options, 5);

		switch(op) {

			case '1':
				return 1;
			case '2':
				return 2;
			case '3':
				return 3;
			case '4':
				return 4;
			case '5':
				return -1;
				
			default:
				fprintf(stderr, "Invalid condition at %s:%d\n", __FILE__, __LINE__);
				abort();
		}

		getchar();
	}
}

static void aggiungi_impiegato(MYSQL *conn){
	MYSQL_STMT *prepared_stmt;
	MYSQL_BIND param[5];
	int matricola;
	char nome[45];
	char cognome[45];
	char passwd[45];
	int ruolo;

	if(!setup_prepared_stmt(&prepared_stmt, "call aggiungi_impiegato(?,?,?,?,?)", conn)) {
		finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize aggiungi_impiegato\n", false);
	}

	// Prepare parameters
	memset(param, 0, sizeof(param));
	memset(nome,'\0', sizeof(nome));
	memset(cognome,'\0', sizeof(cognome));
	memset(passwd,'\0', sizeof(passwd));
	printf("Attenzione le seguenti informazioni sono definitive\n");
	printf("Inserire matricola impiegato:\n");
	
	if(scanf("%i",&matricola)<1){
		printf("Errore inserimento matricola\n");
		flush_stdin();
		return;
	}
	flush_stdin();
	printf("Inserire nome impiegato:\n");
	getInput(45,nome,false);
	printf("Inserire cognome impiegato:\n");
	getInput(45,cognome,false);
	printf("Inserire password impiegato\n");
	getInput(45,passwd,true);

	if((ruolo=choose_role())==-1){
		printf("Non è stato selezionato un ruolo\n");
		return;
	}

	param[0].buffer_type = MYSQL_TYPE_LONG;
	param[0].buffer = &matricola;
	param[0].buffer_length = sizeof(matricola);

	param[1].buffer_type = MYSQL_TYPE_STRING;
	param[1].buffer = nome;
	param[1].buffer_length = sizeof(nome);

	param[2].buffer_type = MYSQL_TYPE_STRING;
	param[2].buffer = cognome;
	param[2].buffer_length = sizeof(cognome);

	param[3].buffer_type = MYSQL_TYPE_STRING;
	param[3].buffer = passwd;
	param[3].buffer_length = sizeof(passwd);

	param[4].buffer_type = MYSQL_TYPE_LONG;
	param[4].buffer = &ruolo;
	param[4].buffer_length = sizeof(ruolo);

	if (mysql_stmt_bind_param(prepared_stmt, param) != 0) {
		finish_with_stmt_error(conn, prepared_stmt, "Could not bind parameters for aggiungi_impiegato\n", true);
	}

	// Run procedure
	if (mysql_stmt_execute(prepared_stmt) != 0) {
		print_stmt_error(prepared_stmt, "Could not add employee\n");
	}else printf("Impiegato aggiunto correttamente\n");

	mysql_stmt_close(prepared_stmt);
}

static void rimuovi_impiegato(MYSQL *conn){
	MYSQL_STMT *prepared_stmt;
	MYSQL_BIND param[1];
	int matricola;

	if(!setup_prepared_stmt(&prepared_stmt, "call rimuovi_impiegato(?)", conn)) {
		finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize aggiungi_rimuovi\n", false);
	}

	// Prepare parameters
	memset(param, 0, sizeof(param));
	
	printf("Inserire matricola impiegato:\n");
	if(scanf("%d",&matricola)<1){
		printf("Errore inserimento matricola\n");
		flush_stdin();
		return;
	}
	flush_stdin();
	param[0].buffer_type = MYSQL_TYPE_LONG;
	param[0].buffer = &matricola;
	param[0].buffer_length = sizeof(matricola);

	if (mysql_stmt_bind_param(prepared_stmt, param) != 0) {
		finish_with_stmt_error(conn, prepared_stmt, "Could not bind parameters for rimuovi_impiegato\n", true);
	}

	// Run procedure
	if (mysql_stmt_execute(prepared_stmt) != 0) {
		print_stmt_error(prepared_stmt, "Could not remove employee\n");
	}else printf("Impiegato rimosso correttamente\n");

	mysql_stmt_close(prepared_stmt);
}

static void gestisci_impiegati(MYSQL *conn){
	char options[5] = {'1','2','3','4'};
	char op;

	while(true) {
		printf("\033[2J\033[H");
		printf("*** Cosa posso fare per te? ***\n\n");
		printf("1) Aggiungi impiegato\n");
		printf("2) Rimuovi impiegato\n");
		printf("3) Visualizza impiegati\n");
		printf("4) Quit\n");

		op = multiChoice("Seleziona un opzione", options, 4);

		switch(op) {

			case '1':
				aggiungi_impiegato(conn);
				break;
			case '2':
				rimuovi_impiegato(conn);
				break;
			case '3':
				visualizza_impiegati(conn);
				break;
			case '4':
				return;
				
			default:
				fprintf(stderr, "Invalid condition at %s:%d\n", __FILE__, __LINE__);
				abort();
		}

		getchar();
	}
}

void run_as_manager(MYSQL *conn){
	char options[10] = {'1','2','3','4','5','6','7','8','9'};
	char op;
	
	printf("Passo al ruolo di manager...\n");

	if(!parse_config("users/manager.json", &conf)) {
		fprintf(stderr, "Unable to load manager configuration\n");
		exit(EXIT_FAILURE);
	}

	if(mysql_change_user(conn, conf.db_username, conf.db_password, conf.database)) {
		fprintf(stderr, "mysql_change_user() failed\n");
		exit(EXIT_FAILURE);
	}

	while(true) {
		printf("\033[2J\033[H");
		printf("*** Cosa posso fare per te? ***\n\n");
		printf("1) Registra cliente\n");
		printf("2) Stampa scontrino\n");
		printf("3) Gestisci prodotti\n");
		printf("4) Gestisci tavoli\n");
		printf("5) Gestisci impiegati\n");
		printf("6) Gestisci turni\n");
		printf("7) Visualizza entrate giornaliere\n");
		printf("8) Visualizza entrate mensili\n");
		printf("9) Quit\n");

		op = multiChoice("Seleziona un opzione", options, 9);

		switch(op) {

			case '1':
				registra_cliente(conn);
				break;
			case '2':
				stampa_scontrino_tavolo(conn);
				break;
			case '3':
				gestisci_prodotti(conn);
				break;
			case '4':
				gestisci_tavoli(conn);
				break;	
			case '5':
				gestisci_impiegati(conn);
				break;
			case '6':
				gestisci_turni(conn);
				break;
			case '7':
				visualizza_entrate_giorno(conn);
				break;
			case '8':
				visualizza_entrate_mese(conn);
				break;	
			case '9':
				return;
				
			default:
				fprintf(stderr, "Invalid condition at %s:%d\n", __FILE__, __LINE__);
				abort();
		}

		getchar();
	}
}
#include "defines.h"

struct configuration conf;
MYSQL *conn;


void new_category() {
	MYSQL_STMT *prepared_stmt;
	MYSQL_BIND param[1];
	
	char name[20];			// name of category
	
	printf("Name of new category: ");
	getInput(20, name, false);
	
	if (!setup_prepared_stmt(&prepared_stmt, "call inserimentoNuovaCategoria(?)", conn)) {
		finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize new category statement\n", false);
	}
	
	memset(param, 0, sizeof(param));
	
	param[0].buffer_type = MYSQL_TYPE_VAR_STRING;
	param[0].buffer = name;
	param[0].buffer_length = strlen(name);
	
	if (mysql_stmt_bind_param(prepared_stmt, param) != 0) {
		finish_with_stmt_error(conn, prepared_stmt, "Unable to bind parameters for a new category\n", true);
	}
	
	if (mysql_stmt_execute(prepared_stmt) != 0) {
		finish_with_stmt_error(conn, prepared_stmt, "Unable to execute the query\n", true);
	}
	
	mysql_stmt_close(prepared_stmt);
	printf("\033[40m\033[1;32m   Successful insertion!\033[0m\n");
}

void view_category() {
	MYSQL_STMT *prepared_stmt;
		
	if (!setup_prepared_stmt(&prepared_stmt, "call visualizzaCategoria()", conn)) {
		finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize view category statement\n", false);
	}
	
	if (mysql_stmt_execute(prepared_stmt) != 0)
		finish_with_stmt_error(conn, prepared_stmt, "Unable to execute the query\n", true);
	else	
		dump_result_set(conn, prepared_stmt, "Online Category list\n");		// dump the result set
	
	mysql_stmt_close(prepared_stmt);
}

void generate_report() {
	MYSQL_STMT *prepared_stmt;
	MYSQL_BIND param[1];
	
	char ucc_username[45];			// user's name for report
	
	printf("User's name: ");
	getInput(45, ucc_username, false);
	
	if (!setup_prepared_stmt(&prepared_stmt, "call generaReport(?)", conn)) {
		finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize report statement\n", false);
	}
	
	memset(param, 0, sizeof(param));
	
	param[0].buffer_type = MYSQL_TYPE_VAR_STRING;
	param[0].buffer = ucc_username;
	param[0].buffer_length = strlen(ucc_username);
	
	if (mysql_stmt_bind_param(prepared_stmt, param) != 0) {
		finish_with_stmt_error(conn, prepared_stmt, "Unable to bind parameters for a new report\n", true);
	}
	
	if (mysql_stmt_execute(prepared_stmt) != 0)
		print_stmt_error(prepared_stmt, NULL);
	else
		printf("\033[40m\033[1;32m   Generation successfully!\033[0m\n");
	
	mysql_stmt_close(prepared_stmt);
}


int run_as_administrator(MYSQL *main_conn, struct configuration main_conf){
	conn = main_conn;
	conf = main_conf;
	int num_list = 4;					// length of list
	char list[4] = {'1','2','3','4'};	// list of choice
	char option;
	
	printf("Welcome %s\n", conf.username);
	
	if(!parse_config("Users/Administrator.json", &conf)) {
		fprintf(stderr, "Unable to load administrator configuration\n");
		exit(EXIT_FAILURE);
	}
	
	if(mysql_change_user(conn, conf.db_username, conf.db_password, conf.database)) {
		fprintf(stderr, "mysql_change_user() failed\n");
		exit(EXIT_FAILURE);
	}
	while(1){		
		printf("\n\e[1m  What would do you want to do? \e[22m\n");
		printf("\033[40m\033[1;34m%c\033[0m) \033[40m\033[1;32mInsert a new category\033[0m\n", list[0]);
		printf("\033[40m\033[1;34m%c\033[0m) \033[40m\033[1;32mView names of the categories online\033[0m\n", list[1]);
		printf("\033[40m\033[1;34m%c\033[0m) \033[40m\033[1;32mGenerate a report\033[0m\n", list[2]);
		printf("\033[40m\033[1;34m%c\033[0m) \033[40m\033[1;32mquit\033[0m\n", list[3]);
				
		multiChoice("\n\033[40m\033[1;32mWhich do you choose?\033[0m", list, num_list, &option);
		if(option == '#') {
			printf("*** Number doesn't exists ***\n");
			continue;
		}
		
		if(option == list[num_list-1]) {
			printf("*** Goodbye Administrator ***\n");
			break;
		}
		
		switch(option) {
			case '1':	
				new_category();
				break;
			case '2':	
				view_category();		
				break;
			case '3':	
				generate_report();
				break;
			default:
				printf("Error to choose a number\n");
		}
	}
	
	return 0;
	
}
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
	} else {
		printf("\033[40m\033[1;32m   Successful insertion!\033[0m\n");
	}
	
	mysql_stmt_close(prepared_stmt);
}

void view_category() {
	MYSQL_STMT *prepared_stmt;
		
	if (!setup_prepared_stmt(&prepared_stmt, "call visualizzaCategoria()", conn)) {
		finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize view category statement\n", false);
	}
	
	if (mysql_stmt_execute(prepared_stmt) != 0)
		print_stmt_error (prepared_stmt, "An error occurred while viewing categories.");
	
	dump_result_set(conn, prepared_stmt, "Online Category list\n");		// dump the result set
	mysql_stmt_next_result(prepared_stmt);
	
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
	int num_list = 4, chosen_num;					// length of list
	char *list[4] = {"1","2","3","4"};	// list of choice
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
		print_color("  What would do you want to do? ", "white", ' ', true, true, false, false);
		print_color(list[0], "light blue", ' ', true, false, false, false); print_color(") Insert a new category", "orange", ' ', false, false, false, false);
		print_color(list[1], "light blue", ' ', true, false, false, false); print_color(") View names of the categories online", "orange", ' ', false, false, false, false);
		print_color(list[2], "light blue", ' ', true, false, false, false); print_color(") Generate a report", "orange", ' ', false, false, false, false);
		print_color(list[3], "light blue", ' ', true, false, false, false); print_color(") Quit", "orange", ' ', false, false, false, false);
				
		multiChoice("\nWhich do you choose?", list, num_list, &chosen_num, &option);
		if(option == '#') {
			print_color("Number doesn't exists", "red", ' ', false, true, false, true);
			continue;
		}
		
		if(chosen_num == num_list-1) {
			printf("*** Goodbye Administrator ***\n");
			break;
		}
		
		switch(chosen_num) {
			case 0:	
				new_category();
				break;
			case 1:	
				view_category();		
				break;
			case 2:	
				generate_report();
				break;
			default:
				print_color("Error to choose a number", "red", ' ', false, true, false, true);
		}
	}
	
	return 0;	
}
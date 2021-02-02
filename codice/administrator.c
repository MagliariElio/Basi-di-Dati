#include "defines.h"

struct configuration conf;
MYSQL *conn;


void new_category() {
	MYSQL_STMT *prepared_stmt;
	MYSQL_BIND param[1];
	
	char name[20];			// name of category
	
	printf("Name of new category: ");
	getInput(20, name, false);
	
	memset(param, 0, sizeof(param));
	
	param[0].buffer_type = MYSQL_TYPE_VAR_STRING;
	param[0].buffer = name;
	param[0].buffer_length = strlen(name);
	

	if (!setup_prepared_stmt(&prepared_stmt, "call inserimentoNuovaCategoria(?)", conn))
		finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize new category statement\n", true);
	
	if (mysql_stmt_bind_param(prepared_stmt, param) != 0)
		finish_with_stmt_error(conn, prepared_stmt, "Unable to bind parameters for a new category\n", true);
	
	if (mysql_stmt_execute(prepared_stmt) != 0)
		print_stmt_error(prepared_stmt, NULL);
	else
		print_color("   Successfully added!", "light blue", ' ', false, true, false, true);	
	
	mysql_stmt_close(prepared_stmt);
	return;
}

void view_category() {
	MYSQL_STMT *prepared_stmt;
		
	if (!setup_prepared_stmt(&prepared_stmt, "call visualizzaCategoria()", conn))
		finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize view category statement\n", true);
	
	if (mysql_stmt_execute(prepared_stmt) != 0)
		print_stmt_error (prepared_stmt, "An error occurred while viewing categories.");
	
	if (mysql_stmt_execute(prepared_stmt) != 0)
			print_stmt_error(prepared_stmt, NULL);
	else {
		dump_result_set(conn, prepared_stmt, "Online Category list\n");		// dump the result set
		mysql_stmt_next_result(prepared_stmt);
	}
		
	mysql_stmt_close(prepared_stmt);
	return;
}

void view_ad_administrator() {
	MYSQL_STMT *prepared_stmt;
	MYSQL_BIND param[3];
	
	char ad_code_string[MAX_AD_CODE_LENGHT], ucc_username[MAX_LENGHT_USERNAME];
	int ad_code;
	
	bool request, is_null;
	
	is_null = 1;
	
	memset(param, 0, sizeof(param));
	
	request = yesOrNo("Do you have any preference on ad?", 'y', 'n');

	if(request == true) {
		print_color("Ad code: ", "light cyan", ' ', false, false, false, false);
		getInput(MAX_AD_CODE_LENGHT, ad_code_string, false);
		ad_code = atoi(ad_code_string);
		param[1].is_null = &is_null;
		goto execution;
	}
	if(request == false){
		param[0].is_null = &is_null;
	}
	
	request = yesOrNo("Do you have any preference on user?", 'y', 'n');

	if(request == true) {
		print_color("Username: ", "yellow", ' ', false, false, false, false);
		getInput(MAX_LENGHT_USERNAME, ucc_username, false);
	}
	if(request == false){
		param[1].is_null = &is_null;
	}
	
	execution:
	
	param[0].buffer_type = MYSQL_TYPE_LONG;
	param[0].buffer = &ad_code;
	param[0].buffer_length = sizeof(ad_code);

	param[1].buffer_type = MYSQL_TYPE_VAR_STRING;
	param[1].buffer = ucc_username;
	param[1].buffer_length = strlen(ucc_username);
	
	param[2].is_null = &is_null;

	if (!setup_prepared_stmt(&prepared_stmt, "call visualizzaAnnuncio (?, ?, ?)", conn))
		finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize ad statement", true);
	
	if (mysql_stmt_bind_param(prepared_stmt, param) != 0)
		finish_with_stmt_error(conn, prepared_stmt, "Unable to bind parameters to view ads\n", true);
	
	if (mysql_stmt_execute(prepared_stmt) != 0)
		print_stmt_error(prepared_stmt, NULL);
	else	
		dump_result_set(conn, prepared_stmt, "Ads list\n");		// dump the result set
	
	mysql_stmt_close(prepared_stmt);
	return;
}

void generate_report() {
	MYSQL_STMT *prepared_stmt;
	MYSQL_BIND param[1];
	
	char ucc_username[MAX_LENGHT_USERNAME];
	
	print_color("Username: ", "yellow", ' ', false, false, false, false);
	getInput(MAX_LENGHT_USERNAME, ucc_username, false);
	
	if (!setup_prepared_stmt(&prepared_stmt, "call generaReport(?)", conn))
		finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize report statement\n", true);
	
	memset(param, 0, sizeof(param));
	
	param[0].buffer_type = MYSQL_TYPE_VAR_STRING;
	param[0].buffer = ucc_username;
	param[0].buffer_length = strlen(ucc_username);
	
	if (mysql_stmt_bind_param(prepared_stmt, param) != 0)
		finish_with_stmt_error(conn, prepared_stmt, "Unable to bind parameters for a new report\n", true);
	
	if (mysql_stmt_execute(prepared_stmt) != 0)
		print_stmt_error(prepared_stmt, NULL);
	else
		print_color("   Successfully generated!", "light blue", ' ', false, true, false, true);
	
	mysql_stmt_close(prepared_stmt);
}


void collect_report() {
	MYSQL_STMT *prepared_stmt;
	MYSQL_BIND param[3];
	
	char ucc_username[MAX_LENGHT_USERNAME], report_code_string[10];
	int report_code;
	
	print_color("Username: ", "yellow", ' ', false, false, false, false);
	getInput(MAX_LENGHT_USERNAME, ucc_username, false);
	
	print_color("Report code: ", "light cyan", ' ', false, false, false, false);
	getInput(10, report_code_string, false);
	report_code = atoi(report_code_string);
	
	memset(param, 0, sizeof(param));
	
	param[0].buffer_type = MYSQL_TYPE_LONG;
	param[0].buffer = &report_code;
	param[0].buffer_length = sizeof(report_code);
	
	param[1].buffer_type = MYSQL_TYPE_VAR_STRING;
	param[1].buffer = ucc_username;
	param[1].buffer_length = strlen(ucc_username);
	
	if (!setup_prepared_stmt(&prepared_stmt, "call riscossioneReport(?, ?)", conn))
		finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize report statement", true);
	
	if (mysql_stmt_bind_param(prepared_stmt, param) != 0)
		finish_with_stmt_error(conn, prepared_stmt, "Unable to bind parameters to collect the report", true);
	
	if (mysql_stmt_execute(prepared_stmt) != 0)
		print_stmt_error(prepared_stmt, NULL);
	else
		print_color("   Successfully collected!", "light blue", ' ', false, true, false, true);
	
	mysql_stmt_close(prepared_stmt);
	return;
}

void view_report() {
	MYSQL_STMT *prepared_stmt;
	MYSQL_BIND param[1];
	
	char ucc_username[MAX_LENGHT_USERNAME];
	
	print_color("Username: ", "yellow", ' ', false, false, false, false);
	getInput(MAX_LENGHT_USERNAME, ucc_username, false);
	
	memset(param, 0, sizeof(param));
	
	param[0].buffer_type = MYSQL_TYPE_VAR_STRING;
	param[0].buffer = ucc_username;
	param[0].buffer_length = strlen(ucc_username);
	
	if (!setup_prepared_stmt(&prepared_stmt, "call visualizza_report(?)", conn))
		finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize report statement", true);
	
	if (mysql_stmt_bind_param(prepared_stmt, param) != 0)
		finish_with_stmt_error(conn, prepared_stmt, "Unable to bind parameters to collect the report", true);
	
	if (mysql_stmt_execute(prepared_stmt) != 0)
		print_stmt_error(prepared_stmt, NULL);
	else
		dump_result_set(conn, prepared_stmt, "Reports\n");
	
	mysql_stmt_close(prepared_stmt);
	return;
}

int run_as_administrator(MYSQL *main_conn, struct configuration main_conf){
	
	conn = main_conn;
	conf = main_conf;
	
	int num_list = 7, chosen_num;																// length of list
	char *list[] = {"1","2","3","4","5","6","7"};												// list of choice
	char option;
	
	print_color("Welcome ", "cyan", ' ', true, false, true, false);
	print_color(conf.username, "cyan", ' ', false, true, true, false);
	
	if(!parse_config("Users/Administrator.json", &conf)) {
		print_color("  Unable to load administrator configuration", "red", ' ', false, true, true, true);
		exit(EXIT_FAILURE);
	}
	
	if(mysql_change_user(conn, conf.db_username, conf.db_password, conf.database)) {
		print_color("  mysql_change_user() failed", "red", ' ', false, true, true, true);
		exit(EXIT_FAILURE);
	}

	while(1){
		
		option = ' ';
		chosen_num = -1;
		
		// Sleep process for 3 seconds so that the new instructions can be read by the user
		//poll(0, 0, 290);
		
		print_color("  What would do you want to do? ", "white", ' ', true, true, false, false);
		print_color(list[0], "light blue", ' ', true, false, false, false); print_color(") Insert a new category", "orange", ' ', false, false, false, false);
		print_color(list[1], "light blue", ' ', true, false, false, false); print_color(") View category names online", "light cyan", ' ', false, false, false, false);
		print_color(list[2], "light blue", ' ', true, false, false, false); print_color(") View ad", "orange", ' ', false, false, false, false);
		print_color(list[3], "light blue", ' ', true, false, false, false); print_color(") Generate a report", "light cyan", ' ', false, false, false, false);
		print_color(list[4], "light blue", ' ', true, false, false, false); print_color(") Collect reports", "orange", ' ', false, false, false, false);
		print_color(list[5], "light blue", ' ', true, false, false, false); print_color(") View reports", "light cyan", ' ', false, false, false, false);
		print_color(list[6], "light blue", ' ', true, false, false, false); print_color(") Quit", "light red", ' ', false, true, false, false);
		
		multiChoice("Which do you choose?", list, num_list, &chosen_num, &option);
		
		if(option == '#') {
			print_color("  Number doesn't exists", "red", ' ', false, true, false, true);
			continue;
		}
		
		if(chosen_num == num_list-1) {
			print_color("  Goodbye ", "orange", ' ', true, false, true, true);
			print_color(conf.username, "orange", ' ', false, true, true, true);
			printf("\n");
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
				view_ad_administrator();
				break;
			case 3:	
				generate_report();
				break;
			case 4:	
				collect_report();
				break;
			case 5:	
				view_report();
				break;
			default:
				print_color("  Error to choose a number", "red", ' ', false, true, false, true);
		}
	}
	
	return 0;		
}

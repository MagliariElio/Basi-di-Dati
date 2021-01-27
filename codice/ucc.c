#include "defines.h"


#define MAX_LENGHT_AD_CODE 10

#define fflush(stdin) while(getchar()!='\n')

struct configuration conf;
MYSQL *conn;
int ad_code;





void new_ad() {
	MYSQL_STMT *prepared_stmt;
	MYSQL_BIND param[5];
	
	char description[100], photo[9], category[20];
	int amount;
	bool request, is_null;
	
	is_null = 1;
	
	memset(param, 0, sizeof(param));
	
	printf("Ad description: ");
	strcpy(description, getInputScanf(100));
	//getInput(100, description, false);
	
	while(1){
		request = yesOrNo("Do you want to add a photo?", 'y', 'n');
			
		if (request == true){
			strcpy(photo, "Presente");
			break;
		}
		
		if(request == false){
			param[2].is_null = &is_null;
			break;
		}
	}
	
	printf("Category: ");
	//getInput(20, category, false);
	strcpy(category, getInputScanf(20));
	
	printf("Amount: ");
	//getInput(6, amount_string, false);
	//amount = atoi(amount_string);
	amount = atoi(getInputScanf(6));
	
	
	param[0].buffer_type = MYSQL_TYPE_VAR_STRING;
	param[0].buffer = description;
	param[0].buffer_length = strlen(description);

	param[1].buffer_type = MYSQL_TYPE_LONG;
	param[1].buffer = &amount;
	param[1].buffer_length = sizeof(amount);

	param[2].buffer_type = MYSQL_TYPE_VAR_STRING;
	param[2].buffer = photo;
	param[2].buffer_length = strlen(photo);
	
	param[3].buffer_type = MYSQL_TYPE_VAR_STRING;
	param[3].buffer = conf.username;
	param[3].buffer_length = strlen(conf.username);
	
	param[4].buffer_type = MYSQL_TYPE_VAR_STRING;
	param[4].buffer = category;
	param[4].buffer_length = strlen(category);
	
		
	if (!setup_prepared_stmt(&prepared_stmt, "call inserimentoNuovoAnnuncio(?, ?, ?, ?, ?)", conn))
		finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize ad statement", false);
	
	if (mysql_stmt_bind_param(prepared_stmt, param) != 0) {
		finish_with_stmt_error(conn, prepared_stmt, "Unable to bind parameters for a new ad\n", true);
	}
	
	if (mysql_stmt_execute(prepared_stmt) != 0)
		print_stmt_error(prepared_stmt, NULL);
	else
		printf("\033[40m\033[1;32m   Successfully generated!\033[0m\n");
	
	mysql_stmt_close(prepared_stmt);
}

bool view_ad(char *username, bool check_owner_value) {
	MYSQL_STMT *prepared_stmt;
	MYSQL_BIND param[3];
	
	int check_owner;
	char ad_code_string[MAX_LENGHT_AD_CODE];
	
	
	if(check_owner_value) {
		
		check_owner = 1;
		
		printf("Ad code: ");	
		getInput(MAX_LENGHT_AD_CODE, ad_code_string, false);
		ad_code = atoi(ad_code_string);
		
		memset(param, 0, sizeof(param));
		
		
		param[0].buffer_type = MYSQL_TYPE_LONG;
		param[0].buffer = &ad_code;
		param[0].buffer_length = sizeof(ad_code);

		param[1].buffer_type = MYSQL_TYPE_VAR_STRING;
		param[1].buffer = username;
		param[1].buffer_length = strlen(username);
		
		param[2].buffer_type = MYSQL_TYPE_LONG;
		param[2].buffer = &check_owner;
		param[2].buffer_length = sizeof(check_owner);
		goto execution;
	}
	
	
	check_owner = 0;
	
	char ucc_username[45];
	bool request, is_null;
	
	is_null = 1;
	check_owner = 0;
	
	memset(param, 0, sizeof(param));
	
	while(1) {
		request = yesOrNo("Do you have any preference on ad?", 'y', 'n');
	
		if(request == true) {
			printf("Ad code: ");		
			getInput(MAX_LENGHT_AD_CODE, ad_code_string, false);
			ad_code = atoi(ad_code_string);
			break;
		}
		if(request == false){
			param[0].is_null = &is_null;
			break;
		}
	}
	
	while(1) {
		request = yesOrNo("Do you have any preference on user?", 'y', 'n');
	
		if(request == true) {
			printf("Username: ");
			getInput(45, ucc_username, false);
			break;
		}
		if(request == false){
			param[1].is_null = &is_null;
			break;
		}
	}
	
	
	param[0].buffer_type = MYSQL_TYPE_LONG;
	param[0].buffer = &ad_code;
	param[0].buffer_length = sizeof(ad_code);

	param[1].buffer_type = MYSQL_TYPE_VAR_STRING;
	param[1].buffer = ucc_username;
	param[1].buffer_length = strlen(ucc_username);
	
	param[2].buffer_type = MYSQL_TYPE_LONG;
	param[2].buffer = &check_owner;
	param[2].buffer_length = sizeof(check_owner);
	
	
	execution:
	
	if (!setup_prepared_stmt(&prepared_stmt, "call visualizzaAnnuncio (?, ?, ?)", conn))
		finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize ad statement", true);
	
	if (mysql_stmt_bind_param(prepared_stmt, param) != 0)
		finish_with_stmt_error(conn, prepared_stmt, "Unable to bind parameters to view ads\n", true);
	
	if (mysql_stmt_execute(prepared_stmt) != 0) {
		print_stmt_error(prepared_stmt, NULL);
		mysql_stmt_close(prepared_stmt);
		return false;
	}
	
	if (!check_owner_value)
		dump_result_set(conn, prepared_stmt, "Ad list\n");		// dump the result set
	
	mysql_stmt_close(prepared_stmt);
	return true;
}


void remove_ad() {
	if(view_ad(conf.username, true) == false)
		return;
	
	MYSQL_STMT *prepared_stmt;
	MYSQL_BIND param[1];
	
	memset(param, 0, sizeof(param));
	
	param[0].buffer_type = MYSQL_TYPE_LONG;
	param[0].buffer = &ad_code;
	param[0].buffer_length = sizeof(ad_code);
	
	if (!setup_prepared_stmt(&prepared_stmt, "call rimuoviAnnuncio (?)", conn))
		finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize ad statement", true);
	
	if (mysql_stmt_bind_param(prepared_stmt, param) != 0)
		finish_with_stmt_error(conn, prepared_stmt, "Unable to bind parameters to view ads\n", true);
	
	if (mysql_stmt_execute(prepared_stmt) != 0)
		print_stmt_error(prepared_stmt, NULL);
	else
		printf("\033[40m\033[1;32m   Successfully removed!\033[0m\n");	
	
	mysql_stmt_close(prepared_stmt);
	
	ad_code = -1;
}

void ad_sold() {
	
	if(view_ad(conf.username, true) == false)
		return;
	
	MYSQL_STMT *prepared_stmt;
	MYSQL_BIND param[1];	
	
	memset(param, 0, sizeof(param));
	
	param[0].buffer_type = MYSQL_TYPE_LONG;
	param[0].buffer = &ad_code;
	param[0].buffer_length = sizeof(ad_code);
	
	if (!setup_prepared_stmt(&prepared_stmt, "call vendutoAnnuncio (?)", conn))
		finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize ad statement", true);
	
	if (mysql_stmt_bind_param(prepared_stmt, param) != 0)
		finish_with_stmt_error(conn, prepared_stmt, "Unable to bind parameters to view ads\n", true);
	
	if (mysql_stmt_execute(prepared_stmt) != 0)
		print_stmt_error(prepared_stmt, NULL);
	else
		printf("\033[40m\033[1;32m   Successfully sold!\033[0m\n");	
	
	mysql_stmt_close(prepared_stmt);
	
	ad_code = -1;
}

int run_as_ucc(MYSQL *main_conn, struct configuration main_conf){
	conn = main_conn;
	conf = main_conf;
	ad_code = -1;
	int num_list = 8;					// length of list
	char list[8] = {'1','2','3','4', '5', '6', '7', '8'};	// list of choice
	char option;
	
	printf("Welcome %s\n", conf.username);
	
	if(!parse_config("Users/UCC.json", &conf)) {
		fprintf(stderr, "Unable to load ucc configuration\n");
		exit(EXIT_FAILURE);
	}
	
	if(mysql_change_user(conn, conf.db_username, conf.db_password, conf.database)) {
		fprintf(stderr, "mysql_change_user() failed\n");
		exit(EXIT_FAILURE);
	}
	while(1){		
		printf("\n\e[1m  What would do you want to do? \e[22m\n");
		printf("\033[40m\033[1;34m%c\033[0m) \033[40m\033[1;32mInsert a new ad\033[0m\n", list[0]);
		printf("\033[40m\033[1;34m%c\033[0m) \033[40m\033[1;32mView ads\033[0m\n", list[1]);
		printf("\033[40m\033[1;34m%c\033[0m) \033[40m\033[1;32mRemove Ad\033[0m\n", list[2]);
		printf("\033[40m\033[1;34m%c\033[0m) \033[40m\033[1;32mSell ad\033[0m\n", list[3]);
		printf("\033[40m\033[1;34m%c\033[0m) \033[40m\033[1;32m............\033[0m\n", list[4]);
		printf("\033[40m\033[1;34m%c\033[0m) \033[40m\033[1;32m............\033[0m\n", list[5]);
		printf("\033[40m\033[1;34m%c\033[0m) \033[40m\033[1;32m............\033[0m\n", list[6]);		
		printf("\033[40m\033[1;34m%c\033[0m) \033[40m\033[1;32mquit\033[0m\n", list[7]);
				
		multiChoice("\n\033[40m\033[1;32mWhich do you choose?\033[0m", list, num_list, &option);
		
		if(option == '#') {
			fprintf (stderr, "\e[1m\e[5m\033[40m\033[31mNumber doesn't exists\033[0m\e[25m\e[22m\n");
			continue;
		}
		
		if(option == list[num_list-1]) {
			printf("Goodbye %s\n", conf.username);
			break;
		}
		
		switch(option) {
			case '1':	
				new_ad();
				break;
			case '2':	
				view_ad("NULL", false);
				break;
			case '3':	
				remove_ad();
				break;
			case '4':	
				ad_sold();
				break;
			case '5':	
				//generate_report();
				break;
			case '6':	
				//generate_report();
				break;
			case '7':	
				//generate_report();
				break;
			case '8':	
				//generate_report();
				break;
			default:
				printf("Error to choose a number\n");
		}
	}
	
	return 0;
	
}
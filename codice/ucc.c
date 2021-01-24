#include "defines.h"

struct configuration conf;
MYSQL *conn;

void new_ad() {
	MYSQL_STMT *prepared_stmt;
	MYSQL_BIND param[3];
	
	char description[100], photo[100];
	int amount;
	bool request, is_null;
	
	printf("Ad description: ");		getInput(100, description, false);
	
	memset(param, 0, sizeof(param));
	
	while(1){
		request = yesOrNo("Do you want to add a photo?", 'y', 'n');
		
		if (request == true){
			printf("Photo: ");		
			getInput(100, photo, false);
			break;
		}
		
		if(request == false){
			param[2].is_null = &is_null;
			break;
		}
	}
	
	printf("Amount: "); 	
	scanf("%d", &amount);
	
	if (!setup_prepared_stmt(&prepared_stmt, "call inserimentoNuovoAnnuncio(?,?,?,?)", conn))
		finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize ad statement", true);

	
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
	
	if (mysql_stmt_bind_param(prepared_stmt, param) != 0)
		finish_with_stmt_error(conn, prepared_stmt, "Unable to bind parameters for a new category\n", true);
	
	if (mysql_stmt_execute(prepared_stmt) != 0)
		print_stmt_error(prepared_stmt, NULL);
	else
		printf("\033[40m\033[1;32m   Generation successfully!\033[0m\n");
	
	mysql_stmt_close(prepared_stmt);
}

void view_own_ad() {
	MYSQL_STMT *prepared_stmt;
	MYSQL_BIND param[2];
	
	int ad_code;
	char ucc_username[45];
	bool request, is_null;
	
	//is_null = true;
	
	if (!setup_prepared_stmt(&prepared_stmt, "call visualizzaAnnuncio (?, ?)", conn))
		finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize ad statement", true);
	
	while(1) {
		request = yesOrNo("Do you have any preference on ad?", 'y', 'n');
	
		if(request == true) {
			printf("Ad code: ");
			scanf("%d", &ad_code);
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
		
	memset(param, 0, sizeof(param));
	
	param[0].buffer_type = MYSQL_TYPE_LONG;
	param[0].buffer = &ad_code;
	param[0].buffer_length = sizeof(ad_code);

	param[1].buffer_type = MYSQL_TYPE_VAR_STRING;
	param[1].buffer = ucc_username;
	param[1].buffer_length = strlen(ucc_username);
	
	if (mysql_stmt_bind_param(prepared_stmt, param) != 0)
		finish_with_stmt_error(conn, prepared_stmt, "Unable to bind parameters for a new category\n", true);
	
	if (mysql_stmt_execute(prepared_stmt) != 0)
		print_stmt_error(prepared_stmt, NULL);
	else
		dump_result_set(conn, prepared_stmt, "Ad list\n");		// dump the result set
	
	mysql_stmt_close(prepared_stmt);
}





int run_as_ucc(MYSQL *main_conn, struct configuration main_conf){
	conn = main_conn;
	conf = main_conf;
	int num_list = 4;					// length of list
	char list[4] = {'1','2','3','4'};	// list of choice
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
		printf("\033[40m\033[1;34m%c\033[0m) \033[40m\033[1;32m........\033[0m\n", list[2]);
		printf("\033[40m\033[1;34m%c\033[0m) \033[40m\033[1;32mquit\033[0m\n", list[3]);
				
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
				view_own_ad();
				break;
			case '3':	
				//view_category();		
				break;
			case '4':	
				//generate_report();
				break;
			default:
				printf("Error to choose a number\n");
		}
	}
	
	return 0;
	
}
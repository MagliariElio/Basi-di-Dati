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
		print_color("   Successfully sold!", "orange", ' ', false, false, false);
	
	mysql_stmt_close(prepared_stmt);
	
	ad_code = -1;
}

void view_personal_information() {
	MYSQL_STMT *prepared_stmt;
	MYSQL_BIND param[1];
	
	bool request;
	
	memset(param, 0, sizeof(param));
	
	request = yesOrNo("Do you want to see your account information?", 'y', 'n');
	if(request) {
		
		param[0].buffer_type = MYSQL_TYPE_VAR_STRING;
		param[0].buffer = conf.username;
		param[0].buffer_length = strlen(conf.username);
		
		if (!setup_prepared_stmt(&prepared_stmt, "call visualizzaUtenteUCC (?)", conn)) {
			finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize ad statement", true);
		}
	} else {
		char cf[16];
		
		printf("Fiscal Code: ");
		getInput(16, cf, false);
		
		param[0].buffer_type = MYSQL_TYPE_VAR_STRING;
		param[0].buffer = cf;
		param[0].buffer_length = strlen(cf);	
			
		if (!setup_prepared_stmt(&prepared_stmt, "call visualizzaInfoAnagrafiche (?)", conn)) {
			finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize ad statement", true);
		}
	}
		
	if (mysql_stmt_bind_param(prepared_stmt, param) != 0)
		finish_with_stmt_error(conn, prepared_stmt, "Unable to bind parameters to view information\n", true);
	
	if (mysql_stmt_execute(prepared_stmt) != 0)
		print_stmt_error(prepared_stmt, NULL);
	else		
		dump_result_set(conn, prepared_stmt, "Personal Information\n");		// dump the result set
	
	mysql_stmt_close(prepared_stmt);
}


void edit_personal_information() {
	MYSQL_STMT *prepared_stmt;
	MYSQL_BIND param[8];
	
	char cf[16], surname[20], name[20], residential_address[20], cap_string[5], billing_address[20], type_favourite_contact[20], favourite_contact[40];
	int cap;
	bool request, is_null;
	
	is_null = 1;
	
	memset(param, 0, sizeof(param));
	
	printf("Your Fiscal Code: ");		
	getInput(16, cf, false);
	
	while(1) {
		request = yesOrNo("Do you want to edit your surname?", 'y', 'n');
	
		if(request == true) {
			printf("Surname: ");		
			getInput(20, surname, false);
			break;
		}
		if(request == false){
			param[1].is_null = &is_null;
			break;
		}
	}
	
	while(1) {
		request = yesOrNo("Do you want to edit your name?", 'y', 'n');
	
		if(request == true) {
			printf("Name: ");
			getInput(20, name, false);
			break;
		}
		if(request == false){
			param[2].is_null = &is_null;
			break;
		}
	}
	
	while(1) {
		request = yesOrNo("Do you want to edit your residential address?", 'y', 'n');
	
		if(request == true) {
			printf("Residential address: ");
			getInput(20, residential_address, false);
			break;
		}
		if(request == false){
			param[3].is_null = &is_null;
			break;
		}
	}
	
	while(1) {
		request = yesOrNo("Do you want to edit your CAP?", 'y', 'n');
	
		if(request == true) {
			printf("CAP: ");
			getInput(5, cap_string, false);
			cap = atoi(cap_string);
			break;
		}
		if(request == false){
			param[4].is_null = &is_null;
			break;
		}
	}
	
	while(1) {
		request = yesOrNo("Do you want to edit your billing address?", 'y', 'n');
	
		if(request == true) {
			printf("Billing address: ");
			getInput(20, billing_address, false);
			break;
		}
		if(request == false){
			param[5].is_null = &is_null;
			break;
		}
	}
	
	while(1) {
		request = yesOrNo("Do you want to edit your favourite contact?", 'y', 'n');
	
		if(request == true) {
			printf("Type of favourite contact: ");
			getInput(20, type_favourite_contact, false);
			printf("Favourite contact: ");
			getInput(40, favourite_contact, false);
			break;
		}
		if(request == false){
			param[6].is_null = &is_null;
			param[7].is_null = &is_null;
			break;
		}
	}
	
	param[0].buffer_type = MYSQL_TYPE_VAR_STRING;
	param[0].buffer = cf;
	param[0].buffer_length = strlen(cf);

	param[1].buffer_type = MYSQL_TYPE_VAR_STRING;
	param[1].buffer = surname;
	param[1].buffer_length = strlen(surname);
	
	param[2].buffer_type = MYSQL_TYPE_VAR_STRING;
	param[2].buffer = name;
	param[2].buffer_length = strlen(name);
	
	param[3].buffer_type = MYSQL_TYPE_VAR_STRING;
	param[3].buffer = residential_address;
	param[3].buffer_length = strlen(residential_address);

	param[4].buffer_type = MYSQL_TYPE_LONG;
	param[4].buffer = &cap;
	param[4].buffer_length = sizeof(cap);
	
	param[5].buffer_type = MYSQL_TYPE_VAR_STRING;
	param[5].buffer = billing_address;
	param[5].buffer_length = strlen(billing_address);
	
	param[6].buffer_type = MYSQL_TYPE_VAR_STRING;
	param[6].buffer = type_favourite_contact;
	param[6].buffer_length = strlen(type_favourite_contact);

	param[7].buffer_type = MYSQL_TYPE_VAR_STRING;
	param[7].buffer = favourite_contact;
	param[7].buffer_length = strlen(favourite_contact);
	
	
	if (!setup_prepared_stmt(&prepared_stmt, "call modificaInfoAnagrafiche (?, ?, ?, ?, ?, ?, ?, ?)", conn))
		finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize ad statement", true);
	
	if (mysql_stmt_bind_param(prepared_stmt, param) != 0)
		finish_with_stmt_error(conn, prepared_stmt, "Unable to bind parameters to edit information\n", true);
	
	if (mysql_stmt_execute(prepared_stmt) != 0)
		print_stmt_error(prepared_stmt, NULL);
	else
		print_color("   Successfully edited!", "orange", ' ', false, false, false);
	
	mysql_stmt_close(prepared_stmt);	
}

int run_as_ucc(MYSQL *main_conn, struct configuration main_conf){
	conn = main_conn;
	conf = main_conf;
	ad_code = -1;
	int num_list = 8;									// length of list
	char list[] = {'1','2','3','4','5','6','7','8'};	// list of choice
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
		print_color("  What would do you want to do? ", "white", ' ', true, true, false);
		print_color("", "light blue", list[0], true, false, false); print_color(") Insert a new ad", "orange", ' ', false, false, false);
		print_color("", "light blue", list[1], true, false, false); print_color(") View ads", "orange", ' ', false, false, false);
		print_color("", "light blue", list[2], true, false, false); print_color(") Remove Ad", "orange", ' ', false, false, false);
		print_color("", "light blue", list[3], true, false, false); print_color(") Sell ad", "orange", ' ', false, false, false);
		print_color("", "light blue", list[4], true, false, false); print_color(") View Personal Information", "orange", ' ', false, false, false);
		print_color("", "light blue", list[5], true, false, false); print_color(") Edit Personal Information", "orange", ' ', false, false, false);
		print_color("", "light blue", list[6], true, false, false); print_color(") ............", "orange", ' ', false, false, false);
		print_color("", "light blue", list[7], true, false, false); print_color(") quit", "orange", ' ', false, false, false);
		
		multiChoice("\nWhich do you choose?", list, num_list, &option);
		
		if(option == '#') {
			fprintf (stderr, print_color("\e[1m\e[5mNumber doesn't exists\e[25m\e[22m\n", "red", ' ', false, false, true));
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
				view_personal_information();
				break;
			case '6':	
				edit_personal_information();
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
#include "defines.h"

struct configuration conf;
static MYSQL *conn;

typedef enum {
	ADMINISTRATOR = 1,
	UCC,
	USCC,
	FAILED_LOGIN
} role_t;

static role_t attempt_login(MYSQL *login_conn, char *username, char *password){
	MYSQL_STMT *login_stored_procedure;
	MYSQL_BIND param[3];
	int role = 0;
	
	if(!setup_prepared_stmt(&login_stored_procedure, "call login(?, ?, ?)", login_conn)) {
		finish_with_stmt_error(login_conn, login_stored_procedure, "Unable to initialize ad statement", true);
		goto err2;
	}
	
	memset(param, 0, sizeof(param));
	
	param[0].buffer_type = MYSQL_TYPE_STRING; 	
	param[0].buffer = username; 				
	param[0].buffer_length = strlen(username); 	

	param[1].buffer_type = MYSQL_TYPE_STRING; 	
	param[1].buffer = password; 				
	param[1].buffer_length = strlen(password); 	

	param[2].buffer_type = MYSQL_TYPE_LONG; 	
	param[2].buffer = &role; 					
	param[2].buffer_length = sizeof(role); 		

	if (mysql_stmt_bind_param(login_stored_procedure, param) != 0) {
		print_stmt_error(login_stored_procedure, "Could not bind parameters for login");
		goto err;
	}
	
	if (mysql_stmt_execute(login_stored_procedure) != 0) {
		print_stmt_error(login_stored_procedure, NULL);
		goto err;
	}
	
	memset(param, 0, sizeof(param));
	
	param[0].buffer_type = MYSQL_TYPE_LONG; 	
	param[0].buffer = &role;					
	param[0].buffer_length = sizeof(role);		
	
	if (mysql_stmt_bind_result(login_stored_procedure, param)) {
		print_stmt_error(login_stored_procedure, "Could not bind result");
		goto err;
	}

	
	if (mysql_stmt_fetch(login_stored_procedure)) {
		print_stmt_error(login_stored_procedure, "Could not fetch result");
		goto err;
	}
	
	mysql_stmt_close(login_stored_procedure);
	return role;
	
	err:
		mysql_stmt_close(login_stored_procedure);
		
	err2:
		return FAILED_LOGIN;	
}

void sign_up(MYSQL *account_conn) {
	
	MYSQL_STMT *prepared_stmt;
	
	char username[MAX_LENGHT_USERNAME], password[MAX_LENGHT_USERNAME], cf[MAX_CF_LENGHT], surname[20], name[20], residential_address[20], billing_address[20], type_favorite_contact[20], favorite_contact[40], type_not_favorite_contact[20], not_favorite_contact[40];
	char cap_string[5];
	int cap;
	
	char *list_choice_type_it[] = {"email", "cellulare", "social", "sms"};
	char *list_choice_type_en[] = {"email", "mobile phone", "social", "sms"};
	int lenght_choice_type = 4;
	
	char favorite_choice[20], not_favorite_choice[20];
	
	bool request, request_billing_address, is_null;
	
	is_null = 1;
	
	print_color("Username: ", "yellow", ' ', false, false, false, false);
	getInput(MAX_LENGHT_USERNAME, username, false);
	
	print_color("Password: ", "yellow", ' ', false, false, false, false);
	getInput(MAX_LENGHT_USERNAME, password, true);
	
	print_color("Tax code: ", "yellow", ' ', false, false, false, false);
	getInput(MAX_CF_LENGHT, cf, false);
	cf[16] = '\0';
	
	print_color("Surname: ", "yellow", ' ', false, false, false, false);
	getInput(20, surname, false);
	
	print_color("Name: ", "yellow", ' ', false, false, false, false);
	getInput(20, name, false);
	
	print_color("Residential address: ", "yellow", ' ', false, false, false, false);
	getInput(20, residential_address, false);
	
	print_color("CAP: ", "light cyan", ' ', false, false, false, false);
	getInput(5, cap_string, false);
	cap = atoi(cap_string);
	
	request_billing_address = yesOrNo("Do you want to edit your billing address?", 'y', 'n');

	if(request_billing_address) {
		print_color("Billing address: ", "yellow", ' ', false, false, false, false);
		getInput(20, billing_address, false);
	}
	
	while(1) {
		print_color("  Which do you choose to enter as your favorite contact?", "orange", ' ', true, true, false, false);
		
		for(int i=0; i<lenght_choice_type; i++) {
			print_color(" - ", "cyan", ' ', false, false, false, false);
			print_color(list_choice_type_en[i], "light blue", ' ', false, true, false, false);
		}
	
		// Take input
		getInput(20, favorite_choice, false);
		for(int i=0; i<lenght_choice_type; i++) {
			
			if(strcmp(list_choice_type_en[i], favorite_choice) == 0) {
				sprintf(type_favorite_contact, "%s", list_choice_type_it[i]);
				type_favorite_contact[strlen(list_choice_type_it[i])] = '\0';
				
				print_color("Contact: ", "yellow", ' ', false, false, false, false);
				getInput(40, favorite_contact, false);
							
				goto execution_favorite_contact;
			}
		}
	}
	
	execution_favorite_contact:
	
	while(1) {
		print_color("  Which do you choose to enter as your not favorite contact?", "orange", ' ', true, true, false, false);
		
		for(int i=0; i<lenght_choice_type; i++) {
			print_color(" - ", "cyan", ' ', false, false, false, false);
			print_color(list_choice_type_en[i], "light blue", ' ', false, true, false, false);
		}
		
		// Take input
		getInput(20, not_favorite_choice, false);
		for(int i=0; i<lenght_choice_type; i++) {
			
			if(strcmp(list_choice_type_en[i], not_favorite_choice) == 0) {
				sprintf(type_not_favorite_contact, "%s", list_choice_type_it[i]);
				type_not_favorite_contact[strlen(list_choice_type_it[i])] = '\0';

				print_color("Contact: ", "yellow", ' ', false, false, false, false);
				getInput(40, not_favorite_contact, false);
				goto execution_not_favorite_contact;
			}
		}
	}
	
	execution_not_favorite_contact:
	
	request = yesOrNo("Do you want to add your credit card number?", 'y', 'n');
	
	if(request) {
		char card_number[17], cvc_string[3], day_string[3], month_string[3], year_string[5]; 
		MYSQL_TIME expiration_date;
		int cvc;
		
		MYSQL_BIND param[15];
		
		memset(param, 0, sizeof(param));
		
		restart_card_number:
		print_color("Card Number: ", "yellow", ' ', false, false, false, false);
		getInput(17, card_number, false);
		card_number[16] = '\0';
		if (strlen(card_number)<16) {
			print_color("   Error Card Number", "light red", ' ', false, true, false, true);
			goto restart_card_number;
		}
		
		restart_cvc:
		print_color("CVC: ", "yellow", ' ', false, false, false, false);
		getInput(3, cvc_string, false);
		cvc_string[3] = '\0';
		cvc = atoi(cvc_string);
		if (strlen(cvc_string)<3) {
			print_color("   Error CVC", "light red", ' ', false, true, false, true);
			goto restart_cvc;
		}
				
		print_color("Enter the expiration date in numeric format", "orange", ' ', true, true, false, false);
		
		restart_day:
		print_color("Day: ", "light cyan", ' ', false, false, false, false);
		getInput(3, day_string, false);
		day_string[2] = '\0';
		if(atoi(day_string)>0 && atoi(day_string)<32) {
			print_color("   Error Day", "light red", ' ', false, true, false, true);
			goto restart_day;
		}
		expiration_date.day = atoi(day_string);
		
		restart_month:
		print_color("Month: ", "light cyan", ' ', false, false, false, false);
		getInput(3, month_string, false);
		month_string[2] = '\0';
		if(atoi(month_string)>0 && atoi(month_string)<13) {
			print_color("   Error Month", "light red", ' ', false, true, false, true);
			goto restart_month;
		}
		expiration_date.month= atoi(month_string);
		
		restart_year:
		print_color("Year: ", "light cyan", ' ', false, false, false, false);
		getInput(5, year_string, false);
		year_string[4] = '\0';
		if(atoi(year_string)>=2021 && atoi(year_string)<2051) {
			print_color("   Error Year", "light red", ' ', false, true, false, true);
			goto restart_year;
		}
		expiration_date.year= atoi(year_string);
		
		if(!request_billing_address)
			param[10].is_null = &is_null;
		
		param[0].buffer_type = MYSQL_TYPE_VAR_STRING;
		param[0].buffer = username;
		param[0].buffer_length = strlen(username);

		param[1].buffer_type = MYSQL_TYPE_VAR_STRING;
		param[1].buffer = password;
		param[1].buffer_length = strlen(surname);
		
		param[2].buffer_type = MYSQL_TYPE_VAR_STRING;
		param[2].buffer = card_number;
		param[2].buffer_length = strlen(card_number);
		
		param[3].buffer_type = MYSQL_TYPE_DATE;
		param[3].buffer = (char *) &expiration_date;
		param[3].buffer_length = sizeof(expiration_date);

		param[4].buffer_type = MYSQL_TYPE_LONG;
		param[4].buffer = &cvc;
		param[4].buffer_length = sizeof(cvc);
		
		param[5].buffer_type = MYSQL_TYPE_VAR_STRING;
		param[5].buffer = cf;
		param[5].buffer_length = strlen(cf);
		
		param[6].buffer_type = MYSQL_TYPE_VAR_STRING;
		param[6].buffer = surname;
		param[6].buffer_length = strlen(surname);

		param[7].buffer_type = MYSQL_TYPE_VAR_STRING;
		param[7].buffer = name;
		param[7].buffer_length = strlen(name);
		
		param[8].buffer_type = MYSQL_TYPE_VAR_STRING;
		param[8].buffer = residential_address;
		param[8].buffer_length = strlen(residential_address);

		param[9].buffer_type = MYSQL_TYPE_LONG;
		param[9].buffer = &cap;
		param[9].buffer_length = sizeof(favorite_contact);
		
		param[10].buffer_type = MYSQL_TYPE_VAR_STRING;
		param[10].buffer = billing_address;
		param[10].buffer_length = strlen(billing_address);
		
		param[11].buffer_type = MYSQL_TYPE_VAR_STRING;
		param[11].buffer = type_favorite_contact;
		param[11].buffer_length = strlen(type_favorite_contact);
		
		param[12].buffer_type = MYSQL_TYPE_VAR_STRING;
		param[12].buffer = favorite_contact;
		param[12].buffer_length = strlen(favorite_contact);
		
		param[13].buffer_type = MYSQL_TYPE_VAR_STRING;
		param[13].buffer = type_not_favorite_contact;
		param[13].buffer_length = strlen(type_not_favorite_contact);
		
		param[14].buffer_type = MYSQL_TYPE_VAR_STRING;
		param[14].buffer = not_favorite_contact;
		param[14].buffer_length = strlen(not_favorite_contact);
		
		if (!setup_prepared_stmt(&prepared_stmt, "call registra_utente_UCC (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", account_conn))
			finish_with_stmt_error(account_conn, prepared_stmt, "Unable to initialize ad statement", true);
		
		if (mysql_stmt_bind_param(prepared_stmt, param) != 0)
			finish_with_stmt_error(account_conn, prepared_stmt, "Unable to bind parameters to create user\n", true);
	} else {
		MYSQL_BIND param[12];
		
		memset(param, 0, sizeof(param));	
		
		if(!request_billing_address)
			param[7].is_null = &is_null;
		
		param[0].buffer_type = MYSQL_TYPE_VAR_STRING;
		param[0].buffer = username;
		param[0].buffer_length = strlen(username);

		param[1].buffer_type = MYSQL_TYPE_VAR_STRING;
		param[1].buffer = password;
		param[1].buffer_length = strlen(surname);
		
		param[2].buffer_type = MYSQL_TYPE_VAR_STRING;
		param[2].buffer = cf;
		param[2].buffer_length = strlen(cf);
		
		param[3].buffer_type = MYSQL_TYPE_VAR_STRING;
		param[3].buffer = surname;
		param[3].buffer_length = strlen(surname);

		param[4].buffer_type = MYSQL_TYPE_VAR_STRING;
		param[4].buffer = name;
		param[4].buffer_length = strlen(name);
		
		param[5].buffer_type = MYSQL_TYPE_VAR_STRING;
		param[5].buffer = residential_address;
		param[5].buffer_length = strlen(residential_address);

		param[6].buffer_type = MYSQL_TYPE_LONG;
		param[6].buffer = &cap;
		param[6].buffer_length = sizeof(favorite_contact);
		
		param[7].buffer_type = MYSQL_TYPE_VAR_STRING;
		param[7].buffer = billing_address;
		param[7].buffer_length = strlen(billing_address);
		
		param[8].buffer_type = MYSQL_TYPE_VAR_STRING;
		param[8].buffer = type_favorite_contact;
		param[8].buffer_length = strlen(type_favorite_contact);
		
		param[9].buffer_type = MYSQL_TYPE_VAR_STRING;
		param[9].buffer = favorite_contact;
		param[9].buffer_length = strlen(favorite_contact);
		
		param[10].buffer_type = MYSQL_TYPE_VAR_STRING;
		param[10].buffer = type_not_favorite_contact;
		param[10].buffer_length = strlen(type_not_favorite_contact);
		
		param[11].buffer_type = MYSQL_TYPE_VAR_STRING;
		param[11].buffer = not_favorite_contact;
		param[11].buffer_length = strlen(not_favorite_contact);	
		
		if (!setup_prepared_stmt(&prepared_stmt, "call registra_utente_USCC (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", account_conn))
			finish_with_stmt_error(account_conn, prepared_stmt, "Unable to initialize ad statement", true);
		
		if (mysql_stmt_bind_param(prepared_stmt, param) != 0)
			finish_with_stmt_error(account_conn, prepared_stmt, "Unable to bind parameters to create user\n", true);
	}
	
	if (mysql_stmt_execute(prepared_stmt) != 0) {
		print_stmt_error(prepared_stmt, NULL);
		mysql_stmt_close(prepared_stmt);
		return;
	}
	else
		print_color("   Successfully created!", "light blue", ' ', false, true, false, true);
	
	mysql_stmt_close(prepared_stmt);
	
	// Sign in account
	strcat(conf.username, username);
	strcat(conf.password, password);
	
	if(request)
		run_as_ucc(account_conn, conf);
	else
		run_as_uscc(account_conn, conf);
	
	return;
}



int main(void){
	role_t role;
	
	if(!parse_config("Users/login.json", &conf)) {
		fprintf(stderr, "Unable to load login configuration\n");
		exit(EXIT_FAILURE);
	}
	
	conn = mysql_init(NULL);		//connection initialized

	if (conn == NULL) {
		fprintf(stderr, "%s\n", mysql_error(conn));
		exit(EXIT_FAILURE);
	}
	
	if (mysql_real_connect(conn, conf.host, conf.db_username, conf.db_password, conf.database, conf.port, NULL, CLIENT_MULTI_STATEMENTS | CLIENT_MULTI_RESULTS) == NULL){ 
		fprintf(stderr, "%s\n", mysql_error(conn));
		mysql_close(conn);
		exit(EXIT_FAILURE);
	}
	
	printf("\n      \t\t\033[40m\033[1;31m@@@@@@@  @@@@@@@@  @@@@@@@  @@   @@  @@@@@@@  @@@@@@@  @@@@@@@\033[0m\n");
	printf("       \t\t\033[40m\033[1;31m@@    @  @@    @@  @@       @@   @@  @@       @@       @@   @@\033[0m\n");
	printf("       \t\t\033[40m\033[1;31m@@@@@@@  @@@@@@@@  @@       @@@@@@@  @@@@@@@  @@       @@@@@@@\033[0m\n");
	printf("       \t\t\033[40m\033[1;31m@@    @  @@    @@  @@       @@   @@  @@       @@       @@   @@\033[0m\n");
	printf("       \t\t\033[40m\033[1;31m@@@@@@@  @@    @@  @@@@@@@  @@   @@  @@@@@@@  @@@@@@@  @@   @@\033[0m\n");
	
	printf("\n\t\e[34m\e[1m@@@@@@@  @@        @@@@@@@  @@@@@@@  @@@@@@@  @@@@@@@  @@@@@@@  @@@@   @@  @@  @@@@@@@  @@@@@@@\e[22m\e[39m\n");
	printf("\t\e[34m\e[1m@@       @@        @@          @@      @@     @@   @@  @@   @@  @@ @@  @@  @@  @@       @@   @@\e[22m\e[39m\n");
	printf("\t\e[34m\e[1m@@@@@@@  @@        @@@@@@@     @@      @@     @@@@@@@  @@   @@  @@  @@ @@  @@  @@       @@@@@@@\e[22m\e[39m\n");
	printf("\t\e[34m\e[1m@@       @@        @@          @@      @@     @@  @@   @@   @@  @@   @@@@  @@  @@       @@   @@\e[22m\e[39m\n");
	printf("\t\e[34m\e[1m@@@@@@@  @@@@@@@@  @@@@@@@     @@      @@     @@   @@  @@@@@@@  @@    @@@  @@  @@@@@@@  @@   @@\e[22m\e[39m\n\n");
	
	if (yesOrNo("\nDo you want to sign up?", 'y', 'n')) {
		sign_up(conn);
		goto restart;
	}
	
	goto start;
	
	restart:	if (yesOrNo("Do you want continue?", 'y', 'n') == false) goto exit;
	
	start:
		//strcat(conf.username, "inglucssi");
		//strcat(conf.password, "da8a0e5a");
		//strcat(conf.username, "ingediero");
		//strcat(conf.password, "a46e76a9");
		strcat(conf.username, "amm1");
		strcat(conf.password, "password");
		
		//print_color("     ENTER YOUR USERNAME AND PASSWORD", "pink", ' ', true, true, false, true);

		//print_color("Username: ", "yellow", ' ', false, false, true, false);
		//getInput(45, conf.username, false);
		//print_color("Password: ", "light cyan", ' ', false, false, false, false);
		//getInput(45, conf.password, true);
	
	role = attempt_login(conn, conf.username, conf.password);
	
	switch(role){
		case ADMINISTRATOR:
			run_as_administrator(conn, conf);
			break;
		case UCC:
			run_as_ucc(conn, conf);
			break;
		case USCC:
			run_as_uscc(conn, conf);
			break;
		case FAILED_LOGIN:
			print_color("Incorrect Username or Password!", "red", ' ', false, true, false, true);
			goto restart;
			break;
		default:
			print_color("Error to login", "red", ' ', false, true, false, true);
			abort();	//it may not delete temporary files and may not flush stream buffer
	}
	goto restart;
	
	exit:
	
		print_color("   Bye!\n", "light blue", ' ', true, true, true, true);
		mysql_close(conn);
		
	return 0;	
}








































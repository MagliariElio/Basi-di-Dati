#include "defines.h"


#define MAX_AD_CODE_LENGHT 10
#define MAX_COMMENT_ID_LENGHT 10

struct configuration conf;
MYSQL *conn;
int ad_code;


void new_ad() {
	MYSQL_STMT *prepared_stmt;
	MYSQL_BIND param[5];
	
	char description[100], photo[9], category[20], amount_string[6];
	int amount;
	bool request, is_null;
	
	is_null = 1;
	
	memset(param, 0, sizeof(param));
	
	print_color("Ad description: ", "yellow", ' ', false, false, false, false);
	strcpy(description, getInput(100, description, false));
	
	request = yesOrNo("Do you want to add a photo?", 'y', 'n');
		
	if (request)
		strcpy(photo, "Presente");
	else
		param[2].is_null = &is_null;
		
	print_color("Category: ", "yellow", ' ', false, false, false, false);
	strcpy(category, getInput(20, category, false));
	
	while(1) {
		print_color("Amount: ", "light cyan", ' ', false, false, false, false);
		getInput(6, amount_string, false);
		amount = atoi(amount_string);
		
		if(amount < 0)
			print_error(NULL, "The amount must be positive");
		else
			break;
	}
	
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
		print_color("   Successfully generated!", "orange", ' ', false, true, false, false);
	
	mysql_stmt_close(prepared_stmt);
	return;
}

bool view_ad(char *username, bool check_owner_value) {
	MYSQL_STMT *prepared_stmt;
	MYSQL_BIND param[3];
	
	int check_owner;										// Parameters are used to check 
	char ad_code_string[MAX_AD_CODE_LENGHT];				// of the owner of the ads for other functions
	
	
	if(check_owner_value) {
		
		check_owner = 1;
		
		printf("Ad code: ");	
		getInput(MAX_AD_CODE_LENGHT, ad_code_string, false);
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
	
	request = yesOrNo("Do you have any preference on ad?", 'y', 'n');

	if(request == true) {
		printf("Ad code: ");		
		getInput(MAX_AD_CODE_LENGHT, ad_code_string, false);
		ad_code = atoi(ad_code_string);
	}
	if(request == false){
		param[0].is_null = &is_null;
	}


	request = yesOrNo("Do you have any preference on user?", 'y', 'n');

	if(request == true) {
		printf("Username: ");
		getInput(45, ucc_username, false);
	}
	if(request == false){
		param[1].is_null = &is_null;
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
		print_color("   Successfully removed!", "orange", ' ', false, true, false, false);
	
	mysql_stmt_close(prepared_stmt);
	
	ad_code = -1;
	return;
}

void ad_sold() {
	
	// Check if the user is the owner
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
		print_color("   Successfully sold!", "orange", ' ', false, true, false, false);
	
	mysql_stmt_close(prepared_stmt);
	
	ad_code = -1;
	return;
}

bool view_personal_information(char cf_owner[16], char username_owner[45], int check_owner) {
	MYSQL_STMT *prepared_stmt;
	
	// Check information for other functions
	if(check_owner == 1){
		MYSQL_BIND param[3];
		
		memset(param, 0, sizeof(param));
		
		param[0].buffer_type = MYSQL_TYPE_VAR_STRING;
		param[0].buffer = cf_owner;
		param[0].buffer_length = strlen(cf_owner);
		
		param[1].buffer_type = MYSQL_TYPE_LONG;
		param[1].buffer = &check_owner;
		param[1].buffer_length = sizeof(check_owner);
		
		param[2].buffer_type = MYSQL_TYPE_VAR_STRING;
		param[2].buffer = username_owner;
		param[2].buffer_length = strlen(username_owner);
		
		if (!setup_prepared_stmt(&prepared_stmt, "call visualizzaInfoAnagrafiche (?, ?, ?)", conn))
			finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize ad statement", true);
		
		if (mysql_stmt_bind_param(prepared_stmt, param) != 0)
			finish_with_stmt_error(conn, prepared_stmt, "Unable to bind parameters to view information\n", true);
		
		goto execution;
	}
	
	
	// View UCC information 
	if(yesOrNo("Do you want to see your account information?", 'y', 'n')) {
		MYSQL_BIND param[1];
		memset(param, 0, sizeof(param));
		
		param[0].buffer_type = MYSQL_TYPE_VAR_STRING;
		param[0].buffer = conf.username;
		param[0].buffer_length = strlen(conf.username);
			
		if (!setup_prepared_stmt(&prepared_stmt, "call visualizzaUtenteUCC (?)", conn))
			finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize ad statement", true);
		
		if (mysql_stmt_bind_param(prepared_stmt, param) != 0)
			finish_with_stmt_error(conn, prepared_stmt, "Unable to bind parameters to view information\n", true);
		
		goto execution;
	}
	
	
	// View personal information
	MYSQL_BIND param[3];
	
	memset(param, 0, sizeof(param));
	
	char cf[16];
	bool is_null;
	
	is_null = 1;
	
	printf("Fiscal Code: ");
	getInput(16, cf, false);
	
	param[0].buffer_type = MYSQL_TYPE_VAR_STRING;
	param[0].buffer = cf;
	param[0].buffer_length = strlen(cf);
	
	param[1].buffer_type = MYSQL_TYPE_VAR_STRING;
	param[1].buffer = cf;
	param[1].buffer_length = strlen(cf);
	param[1].is_null = &is_null;
	
	param[2].buffer_type = MYSQL_TYPE_VAR_STRING;
	param[2].buffer = cf;
	param[2].buffer_length = strlen(cf);
	param[2].is_null = &is_null;
		
	if (!setup_prepared_stmt(&prepared_stmt, "call visualizzaInfoAnagrafiche (?, ?, ?)", conn))
		finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize ad statement", true);
	
	
	if (mysql_stmt_bind_param(prepared_stmt, param) != 0)
		finish_with_stmt_error(conn, prepared_stmt, "Unable to bind parameters to view information\n", true);		
	
	execution:
	if (mysql_stmt_execute(prepared_stmt) != 0) {
		print_stmt_error(prepared_stmt, NULL);
		return false;
	}
		
	if(check_owner != 1)
		dump_result_set(conn, prepared_stmt, "Personal Information\n");		// dump the result set
	
	mysql_stmt_close(prepared_stmt);
	return true;
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
	
	// Check if the user has this fiscal code
	if(!view_personal_information(cf, conf.username, 1))
		return;
	
	request = yesOrNo("Do you want to edit your surname?", 'y', 'n');

	if(request == true) {
		printf("Surname: ");		
		getInput(20, surname, false);
	}
	if(request == false){
		param[1].is_null = &is_null;
	}


	request = yesOrNo("Do you want to edit your name?", 'y', 'n');

	if(request == true) {
		printf("Name: ");
		getInput(20, name, false);
	}
	if(request == false){
		param[2].is_null = &is_null;
	}


	request = yesOrNo("Do you want to edit your residential address?", 'y', 'n');

	if(request == true) {
		printf("Residential address: ");
		getInput(20, residential_address, false);
	}
	if(request == false){
		param[3].is_null = &is_null;
	}


	request = yesOrNo("Do you want to edit your CAP?", 'y', 'n');

	if(request == true) {
		printf("CAP: ");
		getInput(5, cap_string, false);
		cap = atoi(cap_string);
	}
	if(request == false){
		param[4].is_null = &is_null;
	}


	request = yesOrNo("Do you want to edit your billing address?", 'y', 'n');

	if(request == true) {
		printf("Billing address: ");
		getInput(20, billing_address, false);
	}
	if(request == false){
		param[5].is_null = &is_null;
	}


	request = yesOrNo("Do you want to edit your favourite contact?", 'y', 'n');

	if(request == true) {
		printf("Type of favourite contact: ");
		getInput(20, type_favourite_contact, false);
		printf("Favourite contact: ");
		getInput(40, favourite_contact, false);
	}
	if(request == false){
		param[6].is_null = &is_null;
		param[7].is_null = &is_null;
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
		print_color("   Successfully edited!", "orange", ' ', false, true, false, false);
	
	mysql_stmt_close(prepared_stmt);	
	return;
}

void edit_photo_ad() {
	MYSQL_STMT *prepared_stmt;
	MYSQL_BIND param[3];
	
	char ad_code_string[MAX_AD_CODE_LENGHT], photo[9];
	int ad_code_edit;
	
	bool request, is_null;
	
	is_null = 1;

	memset(param, 0, sizeof(param));
	
	printf("Ad Code: ");
	strcpy(ad_code_string, getInput(MAX_AD_CODE_LENGHT, ad_code_string, false));
	ad_code_edit = atoi(ad_code_string);
	
	request = yesOrNo("Do you want to add a photo to an ad?", 'y', 'n');
	
	param[0].buffer_type = MYSQL_TYPE_LONG;
	param[0].buffer = &ad_code_edit;
	param[0].buffer_length = sizeof(ad_code_edit);
	
	param[1].buffer_type = MYSQL_TYPE_VAR_STRING;
	param[1].buffer = conf.username;
	param[1].buffer_length = strlen(conf.username);
	
	
	if(request) {
		strcpy(photo, "Presente");
	}
	else
		param[2].is_null = &is_null;
	
	param[2].buffer_type = MYSQL_TYPE_VAR_STRING;
	param[2].buffer = photo;
	param[2].buffer_length = strlen(photo);
		
	
	if (!setup_prepared_stmt(&prepared_stmt, "call modificaFotoAnnuncio (?, ?, ?)", conn))
		finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize ad statement", true);
	
	if (mysql_stmt_bind_param(prepared_stmt, param) != 0)
		finish_with_stmt_error(conn, prepared_stmt, "Unable to bind parameters to view information\n", true);
	
	if (mysql_stmt_execute(prepared_stmt) != 0)
		print_stmt_error(prepared_stmt, NULL);
	else		
		print_color("   Successfully edited!", "orange", ' ', false, true, false, false);
	
	mysql_stmt_close(prepared_stmt);
	return;
}

void insert_remove_comment() {
	MYSQL_STMT *prepared_stmt;
	MYSQL_BIND param[3];
	
	char ad_code_string[MAX_AD_CODE_LENGHT], id_comment_string[MAX_COMMENT_ID_LENGHT], text[45];
	int ad_code_comment, id_comment;
	
	bool request, is_null;
	
	is_null = 1;

	memset(param, 0, sizeof(param));
	
	print_color("Ad Code: ", "yellow", ' ', false, false, false, false);
	strcpy(ad_code_string, getInput(MAX_AD_CODE_LENGHT, ad_code_string, false));
	ad_code_comment = atoi(ad_code_string);
	
	request = yesOrNo("Do you want to add a comment to an ad?", 'y', 'n');
	
	if(request) {
		print_color("Text of the comment: ", "yellow", ' ', false, false, false, false);
		getInput(45, text, false);
		param[2].is_null = &is_null;
	} else {
		print_color("Comment ID to remove: ", "yellow", ' ', false, false, false, false);
		strcpy(id_comment_string, getInput(MAX_COMMENT_ID_LENGHT, id_comment_string, false));
		id_comment = atoi(id_comment_string);
		param[0].is_null = &is_null;
	}		
	
	param[0].buffer_type = MYSQL_TYPE_VAR_STRING;
	param[0].buffer = text;
	param[0].buffer_length = strlen(text);
	
	param[1].buffer_type = MYSQL_TYPE_LONG;
	param[1].buffer = &ad_code_comment;
	param[1].buffer_length = sizeof(ad_code_comment);
	
	param[2].buffer_type = MYSQL_TYPE_LONG;
	param[2].buffer = &id_comment;
	param[2].buffer_length = sizeof(id_comment);
	
	
	if (!setup_prepared_stmt(&prepared_stmt, "call modificaCommento (?, ?, ?)", conn))
		finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize ad statement", true);
	
	if (mysql_stmt_bind_param(prepared_stmt, param) != 0)
		finish_with_stmt_error(conn, prepared_stmt, "Unable to bind parameters to add or remove comment\n", true);
	
	if (mysql_stmt_execute(prepared_stmt) != 0) {
		print_stmt_error(prepared_stmt, NULL);
		mysql_stmt_close(prepared_stmt);
		return;
	}
	
	if(request)
		print_color("   Successfully added!", "orange", ' ', false, true, false, false);
	else
		print_color("   Successfully removed!", "light red", ' ', false, true, false, false);
	
	mysql_stmt_close(prepared_stmt);
	return;
}


void view_comment() {
	MYSQL_STMT *prepared_stmt;
	MYSQL_BIND param[1];
	
	char ad_code_string[MAX_AD_CODE_LENGHT];
	int ad_code_comment;
	
	memset(param, 0, sizeof(param));
	
	print_color("Ad Code: ", "yellow", ' ', false, false, false, false);
	strcpy(ad_code_string, getInput(MAX_AD_CODE_LENGHT, ad_code_string, false));
	ad_code_comment = atoi(ad_code_string);
		
	param[0].buffer_type = MYSQL_TYPE_LONG;
	param[0].buffer = &ad_code_comment;
	param[0].buffer_length = sizeof(ad_code_comment);	
	
	if (!setup_prepared_stmt(&prepared_stmt, "call visualizzaCommento (?)", conn))
		finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize ad statement", true);
	
	if (mysql_stmt_bind_param(prepared_stmt, param) != 0)
		finish_with_stmt_error(conn, prepared_stmt, "Unable to bind parameters to view comments\n", true);
	
	if (mysql_stmt_execute(prepared_stmt) != 0)
		print_stmt_error(prepared_stmt, NULL);
	else		
		dump_result_set(conn, prepared_stmt, "Comments\n");
	
	mysql_stmt_close(prepared_stmt);
	return;
}


int run_as_ucc(MYSQL *main_conn, struct configuration main_conf){
	conn = main_conn;
	conf = main_conf;
	ad_code = -1;
	int num_list = 10, chosen_num;										// length of list
	char *list[] = {"1","2","3","4","5","6","7","8","9","10"};			// list of choice
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
		print_color("  What would do you want to do? ", "white", ' ', true, true, false, false);
		print_color(list[0], "light blue", ' ', true, false, false, false); print_color(") Insert a new ad", "orange", ' ', false, false, false, false);
		print_color(list[1], "light blue", ' ', true, false, false, false); print_color(") View ads", "orange", ' ', false, false, false, false);
		print_color(list[2], "light blue", ' ', true, false, false, false); print_color(") Remove Ad", "orange", ' ', false, false, false, false);
		print_color(list[3], "light blue", ' ', true, false, false, false); print_color(") Sell ad", "orange", ' ', false, false, false, false);
		print_color(list[4], "light blue", ' ', true, false, false, false); print_color(") View Personal Information", "orange", ' ', false, false, false, false);
		print_color(list[5], "light blue", ' ', true, false, false, false); print_color(") Edit Personal Information", "orange", ' ', false, false, false, false);
		print_color(list[6], "light blue", ' ', true, false, false, false); print_color(") Add or Remove a picture of yours ad", "orange", ' ', false, false, false, false);
		print_color(list[7], "light blue", ' ', true, false, false, false); print_color(") View comments of an ad", "orange", ' ', false, false, false, false);
		print_color(list[8], "light blue", ' ', true, false, false, false); print_color(") Add or Remove a comment to an ad", "orange", ' ', false, false, false, false);
		print_color(list[9], "light blue", ' ', true, false, false, false); print_color(") quit", "orange", ' ', false, true, false, false);
		
		multiChoice("Which do you choose?", list, num_list, &chosen_num, &option);
		
		if(option == '#') {
			print_color("Number doesn't exists", "red", ' ', false, true, false, true);
			continue;
		}
		
		if(chosen_num == num_list-1) {
			printf("Goodbye %s\n", conf.username);
			break;
		}
				
		switch(chosen_num) {
			case 0:	
				new_ad();
				break;
			case 1:	
				view_ad("NULL", false);
				break;
			case 2:	
				remove_ad();
				break;
			case 3:	
				ad_sold();
				break;
			case 4:	
				view_personal_information("", "", 0);
				break;
			case 5:	
				edit_personal_information();
				break;
			case 6:	
				edit_photo_ad();
				break;
			case 7:	
				view_comment();
				break;
			case 8:	
				insert_remove_comment();
				break;
			default:
				print_color("Error to choose a number", "red", ' ', false, true, false, true);
		}
	}
	
	return 0;	
}
#include "defines.h"

struct configuration conf;
MYSQL *conn;

void view_ad_uscc() {
	MYSQL_STMT *prepared_stmt;
	MYSQL_BIND param[3];
	
	
	char ad_code_string[MAX_AD_CODE_LENGHT], ucc_username[45];
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
		getInput(45, ucc_username, false);
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

void view_category_online_uscc() {
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

bool view_personal_information_uscc(char cf_owner[], char username_owner[], int check_owner) {
	MYSQL_STMT *prepared_stmt;
	
	// Check information for other functions
	if(cf_owner != NULL && username_owner != NULL && check_owner == 1){
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
	
	
	// View USCC information 
	if(yesOrNo("Do you want to see your account information?", 'y', 'n')) {
		MYSQL_BIND param[1];
		memset(param, 0, sizeof(param));
		
		param[0].buffer_type = MYSQL_TYPE_VAR_STRING;
		param[0].buffer = conf.username;
		param[0].buffer_length = strlen(conf.username);
			
		if (!setup_prepared_stmt(&prepared_stmt, "call visualizza_Info_Utente (?)", conn))
			finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize ad statement", true);
		
		if (mysql_stmt_bind_param(prepared_stmt, param) != 0)
			finish_with_stmt_error(conn, prepared_stmt, "Unable to bind parameters to view information\n", true);
		
		goto execution;
	}
	
	
	// View personal information
	MYSQL_BIND param[3];
	
	memset(param, 0, sizeof(param));
	
	char cf[MAX_CF_LENGHT];
	bool is_null;
	
	is_null = 1;
	
	print_color("Tax code: ", "yellow", ' ', false, false, false, false);
	getInput(MAX_CF_LENGHT, cf, false);
	cf[16] = '\0';
	
	param[0].buffer_type = MYSQL_TYPE_VAR_STRING;
	param[0].buffer = cf;
	param[0].buffer_length = strlen(cf);
	
	param[1].is_null = &is_null;		// check_owner
	param[2].is_null = &is_null;		// username
		
	if (!setup_prepared_stmt(&prepared_stmt, "call visualizzaInfoAnagrafiche (?, ?, ?)", conn))
		finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize ad statement", true);
	
	
	if (mysql_stmt_bind_param(prepared_stmt, param) != 0)
		finish_with_stmt_error(conn, prepared_stmt, "Unable to bind parameters to view information\n", true);		
	
	execution:
	if (mysql_stmt_execute(prepared_stmt) != 0) {
		print_stmt_error(prepared_stmt, NULL);
		mysql_stmt_close(prepared_stmt);
		return false;
	}
		
	if(check_owner != 1)
		dump_result_set(conn, prepared_stmt, "Personal Information\n");		// dump the result set
	
	
	mysql_stmt_close(prepared_stmt);
	return true;
}

void edit_personal_information_uscc(char cf_set_favorite[], char type_set_favorite[], char contact_set_favorites[]) {
	MYSQL_STMT *prepared_stmt;
	MYSQL_BIND param[8];
	
	memset(param, 0, sizeof(param));
	
	bool is_null = 1;
	
	// Set contact as favorite
	if(cf_set_favorite != NULL && type_set_favorite != NULL && contact_set_favorites != NULL) {
		param[0].buffer_type = MYSQL_TYPE_VAR_STRING;
		param[0].buffer = cf_set_favorite;
		param[0].buffer_length = strlen(cf_set_favorite);

		param[1].is_null = &is_null;
		param[2].is_null = &is_null;
		param[3].is_null = &is_null;
		param[4].is_null = &is_null;
		param[5].is_null = &is_null;

		param[6].buffer_type = MYSQL_TYPE_VAR_STRING;
		param[6].buffer = type_set_favorite;
		param[6].buffer_length = strlen(type_set_favorite);

		param[7].buffer_type = MYSQL_TYPE_VAR_STRING;
		param[7].buffer = contact_set_favorites;
		param[7].buffer_length = strlen(contact_set_favorites);
		
		goto execution;
	}
				
	char cf[MAX_CF_LENGHT], surname[20], name[20], residential_address[20], cap_string[5], billing_address[20], type_favorite_contact[20], favorite_contact[40];
	
	char *list_choice_type_it[] = {"email", "cellulare", "social", "sms"};
	char *list_choice_type_en[] = {"email", "mobile phone", "social", "sms"};
	int lenght_choice_type = 4;
	
	char choice[20];
	int cap;
	
	bool request;
		
	print_color("Tax code: ", "yellow", ' ', false, false, false, false);
	getInput(MAX_CF_LENGHT, cf, false);
	cf[16] = '\0';
	
	// Check if the user has this tax code
	if(!view_personal_information_uscc(cf, conf.username, 1))
		return;
			
	request = yesOrNo("Do you want to edit your surname?", 'y', 'n');

	if(request == true) {	
		print_color("Surname: ", "yellow", ' ', false, false, false, false);
		getInput(20, surname, false);
	}
	if(request == false){
		param[1].is_null = &is_null;
	}

	request = yesOrNo("Do you want to edit your name?", 'y', 'n');

	if(request == true) {
		print_color("Name: ", "yellow", ' ', false, false, false, false);
		getInput(20, name, false);
	}
	if(request == false){
		param[2].is_null = &is_null;
	}

	request = yesOrNo("Do you want to edit your residential address?", 'y', 'n');

	if(request == true) {
		print_color("Residential address: ", "yellow", ' ', false, false, false, false);
		getInput(20, residential_address, false);
	}
	if(request == false){
		param[3].is_null = &is_null;
	}

	request = yesOrNo("Do you want to edit your CAP?", 'y', 'n');

	if(request == true) {
		print_color("CAP: ", "light cyan", ' ', false, false, false, false);
		getInput(5, cap_string, false);
		cap = atoi(cap_string);
	}
	if(request == false){
		param[4].is_null = &is_null;
	}

	request = yesOrNo("Do you want to edit your billing address?", 'y', 'n');

	if(request == true) {
		print_color("Billing address: ", "yellow", ' ', false, false, false, false);
		getInput(20, billing_address, false);
	}
	if(request == false){
		param[5].is_null = &is_null;
	}

	request = yesOrNo("Do you want to edit your favorite contact?", 'y', 'n');
	
	while(1) {
		if (request)
			print_color("  Which do you choose to edit?", "orange", ' ', true, true, false, false);
		else {
			param[6].is_null = &is_null;
			param[7].is_null = &is_null;
			break;
		}
		
		for(int i=0; i<lenght_choice_type; i++) {
			print_color(" - ", "cyan", ' ', false, false, false, false);
			print_color(list_choice_type_en[i], "light blue", ' ', false, true, false, false);
		}
		
		// Take input
		getInput(20, choice, false);
		for(int i=0; i<lenght_choice_type; i++) {
			
			if(strcmp(list_choice_type_en[i], choice) == 0) {
				sprintf(type_favorite_contact, "%s", list_choice_type_it[i]);
				type_favorite_contact[strlen(list_choice_type_it[i])] = '\0';
				
				print_color("Contact: ", "yellow", ' ', false, false, false, false);
				getInput(40, favorite_contact, false);
								
				goto execution_editing_information;
			}
		}
	}
		
	execution_editing_information:
	
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
	param[6].buffer = type_favorite_contact;
	param[6].buffer_length = strlen(type_favorite_contact);

	param[7].buffer_type = MYSQL_TYPE_VAR_STRING;
	param[7].buffer = favorite_contact;
	param[7].buffer_length = strlen(favorite_contact);
	
	execution:
	if (!setup_prepared_stmt(&prepared_stmt, "call modificaInfoAnagrafiche (?, ?, ?, ?, ?, ?, ?, ?)", conn))
		finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize ad statement", true);
	
	if (mysql_stmt_bind_param(prepared_stmt, param) != 0)
		finish_with_stmt_error(conn, prepared_stmt, "Unable to bind parameters to edit information\n", true);
	
	if (mysql_stmt_execute(prepared_stmt) != 0)
		print_stmt_error(prepared_stmt, NULL);
	else
		print_color("   Successfully edited!", "light blue", ' ', false, true, false, true);
	
	mysql_stmt_close(prepared_stmt);	
	return;
}

void insert_comment_uscc() {
	MYSQL_STMT *prepared_stmt;
	MYSQL_BIND param[3];
	
	char ad_code_string[MAX_AD_CODE_LENGHT], text[45];
	int ad_code_comment;
	
	bool is_null;
	
	is_null = 1;

	memset(param, 0, sizeof(param));
	
	print_color("Ad code: ", "light cyan", ' ', false, false, false, false);
	strcpy(ad_code_string, getInput(MAX_AD_CODE_LENGHT, ad_code_string, false));
	ad_code_comment = atoi(ad_code_string);
	
	print_color("Text of the comment: ", "yellow", ' ', false, false, false, false);
	getInput(45, text, false);
	
	param[0].buffer_type = MYSQL_TYPE_VAR_STRING;
	param[0].buffer = text;
	param[0].buffer_length = strlen(text);
	
	param[1].buffer_type = MYSQL_TYPE_LONG;
	param[1].buffer = &ad_code_comment;
	param[1].buffer_length = sizeof(ad_code_comment);
	
	param[2].is_null = &is_null;
	
	if (!setup_prepared_stmt(&prepared_stmt, "call modificaCommento (?, ?, ?)", conn))
		finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize ad statement", true);
	
	if (mysql_stmt_bind_param(prepared_stmt, param) != 0)
		finish_with_stmt_error(conn, prepared_stmt, "Unable to bind parameters to add or remove comment\n", true);
	
	if (mysql_stmt_execute(prepared_stmt) != 0)
		print_stmt_error(prepared_stmt, NULL);
	else
		print_color("   Successfully added!", "light blue", ' ', false, true, false, true);
		
	mysql_stmt_close(prepared_stmt);
	return;
}


void view_comment_uscc() {
	MYSQL_STMT *prepared_stmt;
	MYSQL_BIND param[1];
	
	char ad_code_string[MAX_AD_CODE_LENGHT];
	int ad_code_comment;
	
	memset(param, 0, sizeof(param));
	
	print_color("Ad code: ", "light cyan", ' ', false, false, false, false);
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

void view_note_uscc() {
	MYSQL_STMT *prepared_stmt;
	MYSQL_BIND param[1];
	
	char ad_code_string[MAX_AD_CODE_LENGHT];
	int ad_code_note;
	
	memset(param, 0, sizeof(param));
	
	print_color("Ad code: ", "light cyan", ' ', false, false, false, false);
	strcpy(ad_code_string, getInput(MAX_AD_CODE_LENGHT, ad_code_string, false));
	ad_code_note = atoi(ad_code_string);
		
	param[0].buffer_type = MYSQL_TYPE_LONG;
	param[0].buffer = &ad_code_note;
	param[0].buffer_length = sizeof(ad_code_note);	
	
	if (!setup_prepared_stmt(&prepared_stmt, "call visualizzaNota (?)", conn))
		finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize ad statement", true);
	
	if (mysql_stmt_bind_param(prepared_stmt, param) != 0)
		finish_with_stmt_error(conn, prepared_stmt, "Unable to bind parameters to view note\n", true);
	
	if (mysql_stmt_execute(prepared_stmt) != 0)
		print_stmt_error(prepared_stmt, NULL);
	else		
		dump_result_set(conn, prepared_stmt, "Note\n");
	
	mysql_stmt_close(prepared_stmt);
	return;
}

void insert_remove_contact_uscc() {
	
	char type[20], contact[40], cf[MAX_CF_LENGHT];
	int remove = 1;
	
	char *list_choice_type_it[] = {"email", "cellulare", "social", "sms"}, choice[20];
	char *list_choice_type_en[] = {"email", "mobile phone", "social", "sms"};
	int lenght_choice_type = 4, i;
	
	bool request, request_2, is_null;
	
	is_null = 1;
	
	print_color("Tax code: ", "yellow", ' ', false, false, false, false);
	getInput(MAX_CF_LENGHT, cf, false);
	
	// Check if the user has this tax code
	if(!view_personal_information_uscc(cf, conf.username, 1))
		return;
	
	request = yesOrNo("Do you want to add a contact?", 'y', 'n');
	
	while(1) {
		if (request)
			print_color("Which do you choose to add?", "white", ' ', false, true, false, false);
		else
			print_color("Which do you choose to remove?", "white", ' ', false, true, false, false);
		
		for(i=0; i<lenght_choice_type; i++) {
			print_color(" - ", "cyan", ' ', false, false, false, false);
			print_color(list_choice_type_en[i], "light blue", ' ', false, true, false, false);
		}
		
		// Take input
		getInput(20, choice, false);
		for(i=0; i<lenght_choice_type; i++) {
			
			if(strcmp(list_choice_type_en[i], choice) == 0) {
				sprintf(type, "%s", list_choice_type_it[i]);
				type[strlen(list_choice_type_it[i])] = '\0';

				print_color("Contact: ", "yellow", ' ', false, false, false, false);
				getInput(40, contact, false);
				goto execution;
			}
		}
	}
	
	execution:
		
	if(request) {
		request_2 = yesOrNo("Do you want to set it as a favorite?", 'y', 'n');
		
		// If the user sends yes then it set as favorite
		if (request_2) {
			edit_personal_information_uscc(cf, type, contact);
			return;
		}
	}
	
	MYSQL_STMT *prepared_stmt;
	MYSQL_BIND param[4];
	
	memset(param, 0, sizeof(param));
	
	param[0].buffer_type = MYSQL_TYPE_VAR_STRING;
	param[0].buffer = type;
	param[0].buffer_length = strlen(type);
	
	param[1].buffer_type = MYSQL_TYPE_VAR_STRING;
	param[1].buffer = contact;
	param[1].buffer_length = strlen(contact);
	
	param[2].buffer_type = MYSQL_TYPE_VAR_STRING;
	param[2].buffer = cf;
	param[2].buffer_length = strlen(cf);
	
	param[3].buffer_type = MYSQL_TYPE_LONG;
	param[3].buffer = &remove;
	param[3].buffer_length = sizeof(remove);
	
	// If the user wants to remove a contact
	if(request) 
		param[3].is_null= &is_null;
	
	if (!setup_prepared_stmt(&prepared_stmt, "call modifica_RecapitoNonPreferito (?, ?, ?, ?)", conn))
		finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize ad statement", true);
	
	if (mysql_stmt_bind_param(prepared_stmt, param) != 0)
		finish_with_stmt_error(conn, prepared_stmt, "Unable to bind parameters to add or remove note\n", true);
	
	if (mysql_stmt_execute(prepared_stmt) != 0) {
		print_stmt_error(prepared_stmt, NULL);
		mysql_stmt_close(prepared_stmt);
		return;
	}
	
	if(request)
		print_color("   Successfully added!", "light blue", ' ', false, true, false, true);
	else
		print_color("   Successfully removed!", "light red", ' ', false, true, false, true);
	
	mysql_stmt_close(prepared_stmt);
	return;
}

void view_contact_uscc() {
	MYSQL_STMT *prepared_stmt;
	MYSQL_BIND param[2];
	
	char cf[MAX_CF_LENGHT];
	int favorite = 1;
	
	bool request, is_null;
	
	is_null = 1;
	
	memset(param, 0, sizeof(param));
	
	print_color("Tax code: ", "yellow", ' ', false, false, false, false);
	getInput(MAX_CF_LENGHT, cf, false);
	
	request = yesOrNo("Do you want to see favorite contact?", 'y', 'n');
	
	// Set the var to null
	if(!request)
		param[1].is_null = &is_null;	
	
	param[0].buffer_type = MYSQL_TYPE_VAR_STRING;
	param[0].buffer = cf;
	param[0].buffer_length = strlen(cf);	
	
	param[1].buffer_type = MYSQL_TYPE_LONG;
	param[1].buffer = &favorite;
	param[1].buffer_length = sizeof(favorite);	
	
	if (!setup_prepared_stmt(&prepared_stmt, "call visualizza_contatti (?, ?)", conn))
		finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize ad statement", true);
	
	if (mysql_stmt_bind_param(prepared_stmt, param) != 0)
		finish_with_stmt_error(conn, prepared_stmt, "Unable to bind parameters to view contacts\n", true);
	
	if (mysql_stmt_execute(prepared_stmt) != 0)
		print_stmt_error(prepared_stmt, NULL);
	else		
		dump_result_set(conn, prepared_stmt, "Contacts\n");
	
	mysql_stmt_close(prepared_stmt);
	return;
}

void send_message_uscc() {
	
	char receiver_username[45], text[100];
	
	print_color("   Username of the user that you want to send the message", "white", ' ', true, true, false, false);
	print_color("Username: ", "yellow", ' ', false, false, false, false);
	getInput(45, receiver_username, false);
	
	print_color("Message text: ", "yellow", ' ', false, false, false, false);
	getInput(100, text, false);
	
	MYSQL_STMT *prepared_stmt;
	MYSQL_BIND param[3];
	
	memset(param, 0, sizeof(param));
	
	param[0].buffer_type = MYSQL_TYPE_VAR_STRING;
	param[0].buffer = conf.username;
	param[0].buffer_length = strlen(conf.username);
	
	param[1].buffer_type = MYSQL_TYPE_VAR_STRING;
	param[1].buffer = receiver_username;
	param[1].buffer_length = strlen(receiver_username);
	
	param[2].buffer_type = MYSQL_TYPE_VAR_STRING;
	param[2].buffer = text;
	param[2].buffer_length = strlen(text);
	
	if (!setup_prepared_stmt(&prepared_stmt, "call invioMessaggio (?, ?, ?)", conn))
		finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize ad statement", true);
	
	if (mysql_stmt_bind_param(prepared_stmt, param) != 0)
		finish_with_stmt_error(conn, prepared_stmt, "Unable to bind parameters to send message\n", true);
	
	if (mysql_stmt_execute(prepared_stmt) != 0)
		print_stmt_error(prepared_stmt, NULL);
	else
		print_color("   Successfully sent", "light blue", ' ', false, true, false, true);
	
	mysql_stmt_close(prepared_stmt);
	return;
}

void view_message_uscc() {
	
	char receiver_username[45], code_conversation_string[MAX_CODE_CONVERSATION];
	int code_conversation;
	
	bool request, is_null;
	
	is_null = 1;
	
	print_color("   Username of the user that you want to view the message", "white", ' ', true, true, false, false);
	print_color("Username: ", "yellow", ' ', false, false, false, false);
	getInput(45, receiver_username, false);
		
	MYSQL_STMT *prepared_stmt;
	MYSQL_BIND param[3];
	
	memset(param, 0, sizeof(param));
	
	request = yesOrNo("Do you know the conversation code", 'y', 'n');
		
	if(request) {
		print_color("Code: ", "ligh cyan", ' ', false, false, false, false);
		getInput(MAX_CODE_CONVERSATION, code_conversation_string, false);
		code_conversation = atoi(code_conversation_string);
	} else 
		param[0].is_null = &is_null;
	
	
	param[0].buffer_type = MYSQL_TYPE_LONG;
	param[0].buffer = &code_conversation;
	param[0].buffer_length = sizeof(code_conversation);
	
	param[1].buffer_type = MYSQL_TYPE_VAR_STRING;
	param[1].buffer = conf.username;
	param[1].buffer_length = strlen(conf.username);
	
	param[2].buffer_type = MYSQL_TYPE_VAR_STRING;
	param[2].buffer = receiver_username;
	param[2].buffer_length = strlen(receiver_username);
	
	if (!setup_prepared_stmt(&prepared_stmt, "call visualizzaMessaggio (?, ?, ?)", conn))
		finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize ad statement", true);
	
	if (mysql_stmt_bind_param(prepared_stmt, param) != 0)
		finish_with_stmt_error(conn, prepared_stmt, "Unable to bind parameters to view messages\n", true);
	
	if (mysql_stmt_execute(prepared_stmt) != 0)
		print_stmt_error(prepared_stmt, NULL);
	else
		dump_result_set(conn, prepared_stmt, "Messages\n");
	
	mysql_stmt_close(prepared_stmt);
	return;
}

void view_conversation_history_uscc() {	
	MYSQL_STMT *prepared_stmt;
	MYSQL_BIND param[1];
	
	memset(param, 0, sizeof(param));
	
	param[0].buffer_type = MYSQL_TYPE_VAR_STRING;
	param[0].buffer = conf.username;
	param[0].buffer_length = strlen(conf.username);
	
	if (!setup_prepared_stmt(&prepared_stmt, "call visualizzaStorico_USCC (?)", conn))
		finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize ad statement", true);
	
	if (mysql_stmt_bind_param(prepared_stmt, param) != 0)
		finish_with_stmt_error(conn, prepared_stmt, "Unable to bind parameters to view conversation history\n", true);
	
	if (mysql_stmt_execute(prepared_stmt) != 0)
		print_stmt_error(prepared_stmt, NULL);
	else
		dump_result_set(conn, prepared_stmt, "Conversation history\n");
	
	mysql_stmt_close(prepared_stmt);
	return;
}

void follow_ad_uscc() {
	
	char ad_code_string[MAX_AD_CODE_LENGHT];
	int ad_code_follow;
	
	print_color("   Enter the ad code that you want to follow", "white", ' ', true, true, false, false);
	print_color("Ad code: ", "light cyan", ' ', false, false, false, false);
	getInput(MAX_AD_CODE_LENGHT, ad_code_string, false);
	ad_code_follow = atoi(ad_code_string);
	
	MYSQL_STMT *prepared_stmt;
	MYSQL_BIND param[2];
	
	memset(param, 0, sizeof(param));
	
	param[0].buffer_type = MYSQL_TYPE_LONG;
	param[0].buffer = &ad_code_follow;
	param[0].buffer_length = sizeof(ad_code_follow);
	
	param[1].buffer_type = MYSQL_TYPE_VAR_STRING;
	param[1].buffer = conf.username;
	param[1].buffer_length = strlen(conf.username);
	
	if (!setup_prepared_stmt(&prepared_stmt, "call segui_Annuncio (?, ?)", conn))
		finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize ad statement", true);
	
	if (mysql_stmt_bind_param(prepared_stmt, param) != 0)
		finish_with_stmt_error(conn, prepared_stmt, "Unable to bind parameters to follow the ad\n", true);
	
	if (mysql_stmt_execute(prepared_stmt) != 0)
		print_stmt_error(prepared_stmt, NULL);
	else
		print_color("   Successfully followed", "light blue", ' ', false, true, false, true);
	
	mysql_stmt_close(prepared_stmt);
	return;
}

void view_ad_followed_uscc() {	
	MYSQL_STMT *prepared_stmt;
	MYSQL_BIND param[1];
	
	memset(param, 0, sizeof(param));
	
	param[0].buffer_type = MYSQL_TYPE_VAR_STRING;
	param[0].buffer = conf.username;
	param[0].buffer_length = strlen(conf.username);
	
	if (!setup_prepared_stmt(&prepared_stmt, "call visualizza_Annunci_Seguiti (?)", conn))
		finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize ad statement", true);
	
	if (mysql_stmt_bind_param(prepared_stmt, param) != 0)
		finish_with_stmt_error(conn, prepared_stmt, "Unable to bind parameters to view ad followed\n", true);
	
	if (mysql_stmt_execute(prepared_stmt) != 0)
		print_stmt_error(prepared_stmt, NULL);
	else
		dump_result_set(conn, prepared_stmt, "Ad followed\n");
	
	mysql_stmt_close(prepared_stmt);
	return;
}

void view_new_notifications_uscc() {	
	MYSQL_STMT *prepared_stmt;
	MYSQL_BIND param[1];
	
	memset(param, 0, sizeof(param));
	
	param[0].buffer_type = MYSQL_TYPE_VAR_STRING;
	param[0].buffer = conf.username;
	param[0].buffer_length = strlen(conf.username);
	
	if (!setup_prepared_stmt(&prepared_stmt, "call visualizza_notifiche (?)", conn))
		finish_with_stmt_error(conn, prepared_stmt, "Unable to initialize ad statement", true);
	
	if (mysql_stmt_bind_param(prepared_stmt, param) != 0)
		finish_with_stmt_error(conn, prepared_stmt, "Unable to bind parameters to view new notifications\n", true);
	
	if (mysql_stmt_execute(prepared_stmt) != 0)
		print_stmt_error(prepared_stmt, NULL);
	else
		dump_result_set(conn, prepared_stmt, "New notifications\n");
	
	mysql_stmt_close(prepared_stmt);
	return;
}


int run_as_uscc(MYSQL *main_conn, struct configuration main_conf){
	
	conn = main_conn;
	conf = main_conf;
	
	int num_list = 16, chosen_num;																				// length of list
	char *list[] = {"1","2","3","4","5","6","7","8","9","10", "11", "12", "13", "14", "15", "16"};				// list of choice
	char option;
	
	print_color("Welcome ", "cyan", ' ', true, false, true, false);
	print_color(conf.username, "cyan", ' ', false, true, true, false);
	
	if(!parse_config("Users/USCC.json", &conf)) {
		print_color("  Unable to load uscc configuration", "red", ' ', false, true, true, true);
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
		print_color(list[0], "light blue", ' ', true, false, false, false); print_color(") View ad", "orange", ' ', false, false, false, false);
		print_color(list[1], "light blue", ' ', true, false, false, false); print_color(") View categories", "light cyan", ' ', false, false, false, false);
		print_color(list[2], "light blue", ' ', true, false, false, false); print_color(") View Personal Information", "orange", ' ', false, false, false, false);
		print_color(list[3], "light blue", ' ', true, false, false, false); print_color(") Edit Personal Information", "light cyan", ' ', false, false, false, false);
		print_color(list[4], "light blue", ' ', true, false, false, false); print_color(") View comments of an ad", "orange", ' ', false, false, false, false);
		print_color(list[5], "light blue", ' ', true, false, false, false); print_color(") Add a comment to an ad", "light cyan", ' ', false, false, false, false);
		print_color(list[6], "light blue", ' ', true, false, false, false); print_color(") View note of an ad", "orange", ' ', false, false, false, false);
		print_color(list[7], "light blue", ' ', true, false, false, false); print_color(") View your contacts", "light cyan", ' ', false, false, false, false);
		print_color(list[8], "light blue", ' ', true, false, false, false); print_color(") Add o remove a contact", "orange", ' ', false, false, false, false);
		print_color(list[9], "light blue", ' ', true, false, false, false); print_color(") Send a message", "light cyan", ' ', false, false, false, false);
		print_color(list[10], "light blue", ' ', true, false, false, false); print_color(") View your messages", "orange", ' ', false, false, false, false);
		print_color(list[11], "light blue", ' ', true, false, false, false); print_color(") View your conversation history", "light cyan", ' ', false, false, false, false);
		print_color(list[12], "light blue", ' ', true, false, false, false); print_color(") View new Notifications", "orange", ' ', false, false, false, false);
		print_color(list[13], "light blue", ' ', true, false, false, false); print_color(") Follow an ad", "light cyan", ' ', false, false, false, false);
		print_color(list[14], "light blue", ' ', true, false, false, false); print_color(") View ad followed", "orange", ' ', false, false, false, false);
		print_color(list[15], "light red", ' ', true, false, false, false); print_color(") quit", "light red", ' ', false, true, false, false);

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
				view_ad_uscc();
				break;
			case 1:	
				view_category_online_uscc();
				break;
			case 2:	
				view_personal_information_uscc("", "", 0);
				break;
			case 3:	
				edit_personal_information_uscc(NULL, NULL, NULL);
				break;
			case 4:	
				view_comment_uscc();
				break;
			case 5:	
				insert_comment_uscc();
				break;
			case 6:	
				view_note_uscc();
				break;
			case 7:	
				view_contact_uscc();
				break;
			case 8:	
				insert_remove_contact_uscc();
				break;
			case 9:	
				send_message_uscc();
				break;
			case 10:	
				view_message_uscc();
				break;
			case 11:	
				view_conversation_history_uscc();
				break;
			case 12:
				view_new_notifications_uscc();
				break;
			case 13:	
				follow_ad_uscc();
				break;
			case 14:	
				view_ad_followed_uscc();
				break;
			default:
				print_color("  Error to choose a number", "red", ' ', false, true, false, true);
		}
	}
	
	return 0;		
}

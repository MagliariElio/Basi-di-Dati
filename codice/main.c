
#include "defines.h"

struct configuration conf;
static MYSQL *conn;


typedef enum {
	ADMINISTRATOR = 1,
	UCC,
	USCC,
	FAILED_LOGIN
} role_t;

static role_t attempt_login(MYSQL *conn, char *username, char *password){
	MYSQL_STMT *login_stored_procedure;
	MYSQL_BIND param[3];
	int role = 0;
	
	if(!setup_prepared_stmt(&login_stored_procedure, "call login(?, ?, ?)", conn)) {
		print_stmt_error(login_stored_procedure, "Unable to initialize login statement");
		goto err2;
	}
	
	// Prepare parameters
	memset(param, 0, sizeof(param));
	
	param[0].buffer_type = MYSQL_TYPE_STRING; 	//IN
	param[0].buffer = username; 				//IN
	param[0].buffer_length = strlen(username); 	//IN

	param[1].buffer_type = MYSQL_TYPE_STRING; 	//IN
	param[1].buffer = password; 				//IN
	param[1].buffer_length = strlen(password); 	//IN

	param[2].buffer_type = MYSQL_TYPE_LONG; 	//OUT
	param[2].buffer = &role; 					//OUT
	param[2].buffer_length = sizeof(role); 		//OUT

	if (mysql_stmt_bind_param(login_stored_procedure, param) != 0) {
		print_stmt_error(login_stored_procedure, "Could not bind parameters for login");
		goto err;
	}
	
	if (mysql_stmt_execute(login_stored_procedure) != 0) {
		print_stmt_error(login_stored_procedure, "Could not bind parameters for login");
		goto err;
	}
	
	memset(param, 0, sizeof(param));
	param[0].buffer_type = MYSQL_TYPE_LONG; 	//OUT
	param[0].buffer = &role;					//OUT
	param[0].buffer_length = sizeof(role);		//OUT
	
	if (mysql_stmt_bind_result(login_stored_procedure, param)) {
		print_stmt_error(login_stored_procedure, "Could not bind parameters for login");
		goto err;
	}

	
	if (mysql_stmt_fetch(login_stored_procedure)) {
		print_stmt_error(login_stored_procedure, "Could not bind parameters for login");
		goto err;
	}
	
	
	mysql_stmt_close(login_stored_procedure);
	return role;
	
	err:
		mysql_stmt_close(login_stored_procedure);
		
	err2:
		return FAILED_LOGIN;	
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
	
	if (!mysql_real_connect(conn, conf.host, conf.db_username, conf.db_password, conf.database, conf.port, NULL, 0)){ //probably MULTI_STATEMENTS
		fprintf(stderr, "%s\n", mysql_error(conn));
		mysql_close(conn);
		exit(EXIT_FAILURE);
	}
	printf("Bacheca Elettronica\n");
	//printf("Username: ");
	strcat(conf.username, "amministratore_1");
	strcat(conf.password, "password");
	//getInput(45, conf.username, false);
	//printf("Password: ");
	//getInput(45, conf.password, true);
		
	role = attempt_login(conn, conf.username, conf.password);
	
	switch(role){
		case ADMINISTRATOR:
			run_as_administrator(conn, conf);
			break;
		case UCC:
			printf("UCC\n");
			break;
		case USCC:
			printf("USCC\n");
			break;
		case FAILED_LOGIN:
			printf("### Incorrect Username or Password ###\n");
			break;
		default:
			printf("Error to login\n");
			abort();	//it may not delete temporary files and may not flush stream buffer
	}
	
	printf("Bye!\n");
	mysql_close(conn);
		
	return 0;	
}








































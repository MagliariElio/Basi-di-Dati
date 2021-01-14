#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <mysql/mysql.h>
#include <stdbool.h>
#include <termios.h>


/*dichiaro le varicabili di connessione*/
static char *opt_host_name = "localhost";				/*host(default=localhost)*/
static char *opt_user_name = "root";					/*username(default=loginname)*/
static char *opt_password = NULL;						/*password(default=none)*/
static unsigned intopt_port_num = 3306;					/*portnumber(usebuilt-in)*/
static char *opt_socket_name = NULL;					/*socketname(usebuilt-in)*/
static char *opt_db_name = "BachecaElettronicadb";		/*databasename(default=none)*/
static unsigned intopt_flags = 0;						/*connecti	onflags(none)*/
static MYSQL *conn;										/*pointertoconnectionhandler*/

void login(){
	MYSQL_RES *res;		//il puntatore alla risorsa mysql
	MYSQL_ROW row;		//il vettore in cui verranno messi i risultati delle query
	
	/*inizializzo la connessione*/
	conn = mysql_init(NULL);
	
	if (!mysql_real_connect(conn, opt_host_name, opt_user_name, opt_password, opt_db_name, intopt_port_num, opt_socket_name, intopt_flags)){
		fprintf(stderr, "%s\n", mysql_error(conn));
		exit(1);
	}
	
	char *query = "show tables";
	if (mysql_query(conn, query)){
		fprintf(stderr, "%s\n", mysql_error(conn));
		exit(1);
	}
	
	res = mysql_use_result(conn);
	
	/*Stampo a video i risultati della query*/
	while((row = mysql_fetch_row(res)) != NULL){
		printf("%s \n", row[0]);
	}
	
	mysql_free_result(res);
	mysql_close(conn);
}



int main(void){
	MYSQL_RES *res;		//il puntatore alla risorsa mysql
	MYSQL_ROW row;		//il vettore in cui verranno messi i risultati delle query
	char *username, *password;
	
	printf("Database: %s\n", opt_db_name);
	printf("Username: ");
	if (scanf("%ms", &username) == EOF) {
		printf("Error to insert username\n");
		free(username);
		exit(1);
	}
	printf("Passoword: ");
	getpasswd(&password, 200, '*', stdin);
	/*if (scanf("%ms", &password) == EOF){
		printf("Error to insert password\n");
		free(password);
		exit(1);
	}*/
	
	/*inizializzo la connessione*/
	conn = mysql_init(NULL);
	
	if (!mysql_real_connect(conn, opt_host_name, opt_user_name, opt_password, opt_db_name, intopt_port_num, opt_socket_name, intopt_flags)){
		fprintf(stderr, "%s\n", mysql_error(conn));
		exit(1);
	}
	
	char *query = "show tables";
	if (mysql_query(conn, query)){
		fprintf(stderr, "%s\n", mysql_error(conn));
		exit(1);
	}
	
	res = mysql_use_result(conn);
	
	/*Stampo a video i risultati della query*/
	while((row = mysql_fetch_row(res)) != NULL){
		printf("%s \n", row[0]);
	}
	
	mysql_free_result(res);
	mysql_close(conn);
	
	return 0;	
}
#pragma once

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <mysql.h>


struct configuration {
	char *host;
	char *db_username;
	char *db_password;
	unsigned int port;
	char *database;

	char username[45];
	char password[45];
};

extern struct configuration conf;

extern int parse_config(char *path, struct configuration *conf);
extern char *getInput(unsigned int lung, char *stringa, bool hide);
extern char *getInputScanf(int length_max);
extern bool yesOrNo(char *domanda, char yes, char no);
extern char *print_color(char *stringa, char *colore_scelto, char c, bool first_space, bool bold, bool error);
extern void multiChoice(char *domanda, char choices[], int num, char *option);
extern void print_error (MYSQL *conn, char *message);
extern void print_stmt_error (MYSQL_STMT *stmt, char *message);
extern void finish_with_error(MYSQL *conn, char *message);
extern void finish_with_stmt_error(MYSQL *conn, MYSQL_STMT *stmt, char *message, bool close_stmt);
extern bool setup_prepared_stmt(MYSQL_STMT **stmt, char *statement, MYSQL *conn);
extern void dump_result_set(MYSQL *conn, MYSQL_STMT *stmt, char *title);
extern int run_as_administrator(MYSQL *conn, struct configuration conf);
extern int run_as_ucc(MYSQL *conn, struct configuration conf);
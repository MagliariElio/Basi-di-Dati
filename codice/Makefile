CC = gcc
OTPS = `mysql_config --cflags --include --libs`

all: 
	$(CC) -Wall -Wextra *.c -o main $(OTPS)

clean:
	rm *.o main

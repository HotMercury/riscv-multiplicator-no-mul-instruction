CC=gcc
CFLAG=-Wall -g

main: floating_multiplication.c
	$(CC) $(CFLAG) -o main floating_multiplication.c

test: IEEE_float_transfer.c
	$(CC) $(CFLAG) -o test IEEE_float_transfer.c

clean: 
	rm -f test main
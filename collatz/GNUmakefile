CFLAGS = -Wall -O9
all: collatz collatz2 collatz3 modf

collatz:

collatz2: collatz2.o
	$(CC) -o $@ $^ -lm

clean:
	rm -f collatz collatz2 collatz3 modf *.o core

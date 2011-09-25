#include <stdio.h>
#include <stdlib.h>

#define USE_INT 1

#ifdef USE_INT
    typedef int T;
    #define FT "%d"
    #define even(x) ((x) % 2 == 0)
#elif USE_LONG
    typedef long T;
    #define FT "%ld"
    #define even(x) ((x) % 2 == 0)
#elif USE_DOUBLE
    typedef double T;
    #define FT "%20g"
    #define even(x) (floor((x) / 2) == ((x) / 2))
#endif

long collatz(T j) {

    long c = 0;
    while (j != 1) {
	printf("%ld: " FT "\n", c, j);
	if (even(j)) {
	    j = j / 2;
	} else {
	    j = j * 3 + 1;
	}
	c++;
    }
    return c;
}

int main(void) {
    T i = 113383;
    long c = collatz(i);
    printf("%ld\n", c);
    return 0;
}

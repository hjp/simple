#include <stdio.h>
#include <stdlib.h>

#define USE_INT 1

#ifdef USE_INT
    typedef int T;
    #define FT "%d"
    #define odd(x) ((x) % 2 == 1)
#elif USE_LONG
    typedef long T;
    #define FT "%ld"
    #define odd(x) ((x) % 2 == 1)
#elif USE_DOUBLE
    typedef double T;
    #define FT "%20g"
    #define odd(x) (floor((x) / 2) != ((x) / 2))
#endif

long collatz(T j) {

    long c = 0;
    while (j != 1) {
	printf("%ld: " FT "\n", c, j);
	if (odd(j)) {
	    j = j * 3 + 1;
	} else {
	    j = j / 2;
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

#include <stdio.h>
#include <stdlib.h>

typedef int T;
#define FT "%d"

int main(void) {
    T i = 1;
    long c_max = 0;

    for(;;) {
	T j = i;
	long c = 0;
	while (j != 1) {
	    if (j % 2 == 1) {
		T j2 = j * 3 + 1;
		if ((j2 - 1) / 3 != j) {
		    printf(FT " is not 3 * " FT " + 1 at starting point " FT, j2, j, i);
		    exit(1);
		} 
		j = j2;
	    } else {
		j = j / 2;
	    }
	    c++;
	}
	if (c > c_max) {
	    printf("new longest sequence starting at " FT ": %ld steps\n", i, c);
	    c_max = c;
	}

	if (i + 1 > i) {
	    i = i + 1;
	} else {
	    printf(FT " is not greater than " FT "\n", i + 1, i);
	    exit(1);
	}

    }
}

#include <stdio.h>

int main (int argc, char **argv) {
	int i;
	for (i = 0; i < 256; i++) {
		printf ("%x %d %o %c\t", i, i, i, i);
		if (i % 4 == 3) printf ("\n");
	}
	return 0;
}

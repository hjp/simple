#include <limits.h>
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char **argv) {
    unsigned long start = 0;
    unsigned long stop = ULONG_MAX;
    unsigned long i;

    switch (argc) {
    case 0:
    case 1:
	break;
    case 2:
	stop = strtoul(argv[1], NULL, 0);
	break;
    case 3:
	start = strtoul(argv[1], NULL, 0);
	stop = strtoul(argv[2], NULL, 0);
	break;
    default:
	fprintf(stderr, "Usage: %s [[start] stop]\n", argv[0]);
	exit(1);
    }

    for (i = start; i < stop; i++) {
	printf("%d\n", i);
    }
    return 0;
}

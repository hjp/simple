#include <stdio.h>
#include <stdlib.h>
#include <string.h>

char *cmnd;

void usage(void) {
    fprintf(stderr, "Usage: %s errno ...\n", cmnd);
    exit(1);
}


int main(int argc, char **argv) {
    int i;

    cmnd = argv[0];

    if (argc <= 1) usage();

    for (i = 1; i < argc; i++) {
	int e = strtoul(argv[i], NULL, 0);

	printf("%d\t%s\n", e, strerror(e));
    }
    return 0;
}

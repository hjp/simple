#include <stdio.h>
#include <time.h>
#include <stdlib.h>

char *cmnd;

void usage(void) {
    fprintf(stderr, "Usage: %s time_t ...\n", cmnd);
    exit(1);
}


int main(int argc, char **argv) {
    int i;

    cmnd = argv[0];

    if (argc <= 1) usage();

    for (i = 1; i < argc; i++) {
	time_t t = strtoul(argv[i], NULL, 0);
	struct tm *tmp;
	char buf[32];

	printf("%lu\t", t);
	tmp = localtime(&t);
	strftime(buf, sizeof(buf), "%Y-%m-%d %H:%M:%S %Z", tmp);
	printf("%s\n", buf);
    }
    return 0;
}

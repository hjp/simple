#include <netdb.h>
#include <stdio.h>
#include <stdlib.h>

#include "hstrerror.h"

char *cmnd;

void usage(void) {
    fprintf(stderr, "Usage: %s [hostname ...]\n", cmnd);
    exit(1);
}

int main(int argc, char **argv) {
    int i;
    int rc = 0;

    cmnd = argv[0];

    if (argc < 2) {
	usage();
    }

    for (i = 1; i < argc; i++) {
	struct hostent *he = gethostbyname(argv[i]);

	if (!he) {
	    fprintf(stderr, "%s: cannot resolve %s: %s\n",
	    	    argv[0], argv[i], hstrerror(h_errno));
	    rc++;
	    continue;
	}

	printf("%s\n", he->h_name);
    }
    return rc;
}

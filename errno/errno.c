#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "errno_list.h"

char *cmnd;

static void usage(void) {
    fprintf(stderr, "Usage: %s errno ...\n", cmnd);
    exit(1);
}


int main(int argc, char **argv) {
    int i;

    cmnd = argv[0];

    if (argc <= 1) {
	int i;
	for (i = 0; i < wke_nr; i++) {
	    int e = wke[i].number;
	    char *d = wke[i].define;
	    printf("%d\t%s\t%s\n", e, d, strerror(e));
	}
    } else {
	for (i = 1; i < argc; i++) {
	    int e = strtoul(argv[i], NULL, 0);
	    char *d = "(unknown)";
	    int j;

	    for (j = 0; j < wke_nr; j++) {
		if (wke[j].number == e) {
		    d = wke[j].define;
		    break;
		}
	    }

	    printf("%d\t%s\t%s\n", e, d, strerror(e));
	}
    }
    return 0;
}
/*
 * vim:sw=4
 */

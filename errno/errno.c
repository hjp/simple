#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "errno_list.h"

char errno_c_rcs_id[] = "$Id: errno.c,v 1.5 2003-02-27 13:28:45 hjp Exp $";
char *cmnd;

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
	    char *p;
	    int e = strtoul(argv[i], &p, 0);

	    if (*p) {
		/* This is not a number, so we assume it is a define */
		char *d = argv[i];
		int j;

		for (j = 0; j < wke_nr; j++) {
		    if (strcmp(wke[j].define, d) == 0) {
			e = wke[j].number;
			printf("%d\t%s\t%s\n", e, d, strerror(e));
			break;
		    }
		}

	    } else {
		/* it is a number */
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
    }
    return 0;
}
/*
 * vim:sw=4
 */

char scat_c_cvs_version[] = 
    "$Id: scat.c,v 1.2 1999-08-01 18:09:09 hjp Exp $";
/* scat - safe cat
 *
 * catenate input files and print to standard output.
 * replace all non-printable characters with C \xXX escapes.
 *
 * $Log: scat.c,v $
 * Revision 1.2  1999-08-01 18:09:09  hjp
 * First release
 *
 */
#include <ctype.h>
#include <errno.h>
#include <locale.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <features.h>
#include <nl_types.h>

#include "scat.h"

char *cmnd;
nl_catd catalog;

void usage(void) {
    fprintf(stderr,
	    catgets(catalog, MSG_Set, MSG_USAGE, 
		    "Usage: %s [file ...]\n"),
	    cmnd);
    exit(1);
}


void do_safecat(const char *filename) {
    FILE *fp;
    int c;


    if (strcmp(filename, "-") == 0) {
	fp = stdin;
    } else {
	if ((fp = fopen(filename, "r")) == NULL) {
	    fprintf(stderr, catgets(catalog, MSG_Set, MSG_OPEN, 
	                    "%s: cannot open `%s' for reading: %s\n"),
	            cmnd, filename, strerror(errno));
	    exit(1);
	}
    }
    while ((c = getc(fp)) != EOF) {
	if (isprint(c) || isspace(c)) {
	    if (putchar(c) == EOF) {
		fprintf(stderr,
			catgets(catalog, MSG_Set, MSG_WRITE, 
				"%s: cannot write stdout: %s\n"),
			cmnd, strerror(errno));
		exit(1);
	    }
	} else {
	    if (printf("\\x%02X", c) == EOF) {
		fprintf(stderr,
			catgets(catalog, MSG_Set, MSG_WRITE, 
				"%s: cannot write stdout: %s\n"),
			cmnd, strerror(errno));
		exit(1);
	    }
	}
    }
    if (ferror(fp)) {
	fprintf(stderr,
		catgets(catalog, MSG_Set, MSG_READ, 
			"%s: cannot read from `%s': %s\n"),
		cmnd, filename, strerror(errno));
	exit(1);
    }
    if (strcmp(filename, "-") == 0) {
    } else {
	fclose(fp);
    }

}


int main(int argc, char **argv) {
    setlocale(LC_ALL, "");

    cmnd = argv[0];
    catalog = catopen("scat", 0);
    if (argc == 1) {
	do_safecat("-");
    } else {
	int i;
	for (i = 1; i < argc; i++) {
	    do_safecat(argv[i]);
	}
    }
    return 0;
}

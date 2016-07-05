/*
 * fqdn - print fully qualified domain name(s)
 *
 * resolve all host names given on the comman line and print their
 * fully qualified canonical names.
 *
 * If no argument is given, print the system's FQDN.
 */

#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <unistd.h>
#include <netdb.h>

#include "hstrerror.h"

char cvs_id[] = "$Id: fqdn.c,v 1.5 2004-05-17 18:13:46 hjp Exp $";

char *cmnd;

void usage(void) {
    fprintf(stderr, "Usage: %s [hostname ...]\n", cmnd);
    exit(1);
}

int main(int argc, char **argv) {
    int i;
    int rc = 0;
    char hostname[256];
    char *fake_argv[] = { NULL, hostname, NULL };

    cmnd = argv[0];

    if (argc < 2) {
	if (gethostname(hostname, sizeof(hostname)) == -1) {
	    fprintf(stderr, "%s: cannot get hostname: %s\n",
		    cmnd, strerror(errno));
	    exit(1);
	}
	argv = fake_argv;
	argc = 2;
    }

    for (i = 1; i < argc; i++) {
	struct hostent *he = gethostbyname(argv[i]);
	int found = 0;

	if (!he) {
	    fprintf(stderr, "%s: cannot resolve %s: %s\n",
	    	    cmnd, argv[i], hstrerror(h_errno));
	    rc++;
	    continue;
	}

	if (strchr(he->h_name, '.')) {
	    printf("%s\n", he->h_name);
	    found = 1;
	} else {
	    char **a;
	    fprintf(stderr, "Canonical name doesn't contain a dot.\n");
	    fprintf(stderr, "Please shoot the administrator of this box.\n");
	    fprintf(stderr, "In the mean time I try to find a suitable alias.\n");
	    for (a = he->h_aliases; !found && *a; a++) {
		if (strchr(*a, '.')) {
		    printf("%s\n", *a);
		    found = 1;
		}
	    }
	    if (!found) {
		fprintf(stderr, "No alias, either. Consider more painful methods than shooting.\n");
		rc++;
	    }
	}

    }
    return rc;
}

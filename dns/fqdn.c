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

char cvs_id[] = "$Id: fqdn.c,v 1.2 2002-08-14 19:03:52 hjp Exp $";

char *cmnd;

void usage(void) {
    fprintf(stderr, "Usage: %s [hostname ...]\n", cmnd);
    exit(1);
}

int main(int argc, char **argv) {
    int i;
    int rc = 0;
    char hostname[256];
    char *fake_argv[] = { argv[0], hostname, NULL };

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

#include <netdb.h>
#include <stdio.h>
#include <stdlib.h>

#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

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
        struct in_addr ia;
        if (!inet_aton(argv[i], &ia)) {
            fprintf(stderr, "%s: cannot parse %s\n",
                    argv[0], argv[i]);
            continue;
        }
	struct hostent *he = gethostbyaddr(&ia, sizeof(ia), AF_INET);
	char **a;

	if (!he) {
	    fprintf(stderr, "%s: cannot resolve %s: %s\n",
	    	    argv[0], argv[i], hstrerror(h_errno));
	    rc++;
	    continue;
	}

	printf("%s\n", argv[i]);
	printf("\tCanonical:  %s\n", he->h_name);
	for (a = he->h_aliases; *a; a++) {
	    printf("\tAlias:      %s\n", *a);
	}
	for (a = he->h_addr_list; *a; a++) {
	    int j;
	    printf("\tAddress:    ");
	    for (j = 0; j < he->h_length; j++) {
		printf("%s%d", j ? "." : "", (unsigned char)(*a)[j]);
	    }
	    printf("\n");
	}
	printf("\n");
    }
    return rc;
}

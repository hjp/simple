#include <assert.h>
#include <errno.h>
#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

char *cmnd; 

static void usage(void) {
    fprintf(stderr, "Usage: %s [-d delay] file ...\n", cmnd);
    exit(1);
}


static void do_cat(FILE *fp, double delay) {
    int c;

    while ((c = getc(fp)) != EOF) {
	putchar(c);
	usleep(delay * 1E6);
    }
}


int main(int argc, char **argv) {
    int rc = 0;
    int c;
    double delay = 0.5;

    cmnd = argv[0];

    while ((c = getopt(argc, argv, "d:")) != EOF) {
        char *p;
	switch (c) {
	    case 'd':
		p = NULL;
		delay = strtod(optarg, &p);
		if (!p || *p) usage();
		if (delay < 0 || delay > ULONG_MAX / 1E6) usage();
		break;
	    case '?':
		usage();
	    default:
		assert(0);
	}
    }

    setvbuf(stdout, NULL, _IONBF, 0);

    if (optind == argc) {
	do_cat(stdin, delay);
    } else {
	int i;

	for (i = optind; i < argc; i++) {
	    FILE *fp = fopen(argv[i], "r");
	    if (fp) {
		do_cat(fp, delay);
		fclose(fp);
	    } else {
		fprintf(stderr, "%s: cannot open %s for reading: %s\n",
			argv[0], argv[i], strerror(errno));
		rc++;
	    }
	}
    }
    return rc;
}

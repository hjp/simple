#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <time.h>
#include <unistd.h>

static char *cmnd;

static void usage(void) {
    fprintf(stderr, "Usage: %s [-u]\n", cmnd);
    exit(1);
}


int main(int argc, char **argv) {
    int c;
    int use_microseconds = 0;
    int print_ts = 1;

    cmnd = argv[0];

    while ((c = getopt(argc, argv, "u")) != EOF) {
	switch (c) {
	    case 'u':
		use_microseconds = 1;
		break;
	    default:
		usage();
	}
    }
    while ((c = getchar()) != EOF) {
	if (print_ts) {
	    struct timeval tv;
	    char s[sizeof("yyyy-mm-ddThh:mm:ss")];
	    gettimeofday(&tv, NULL);
	    strftime(s, sizeof(s), "%Y-%m-%dT%H:%M:%S",
		     localtime(&tv.tv_sec));
	    fputs(s, stdout);
	    if (use_microseconds) {
		printf(".%06ld ", (long)tv.tv_usec);
	    }
	    putchar(' ');
	    print_ts = 0;
	}
	putchar(c);
	if (c == '\n') print_ts = 1;
    }
    if (!print_ts) putchar('\n');	// force newline at end of output
    return 0;
}

#include <assert.h>
#include <stdio.h>
#include <time.h>
#include <stdlib.h>
#include <unistd.h>

char *cmnd;

static void usage(void) {
    fprintf(stderr, "Usage: %s [-f format] time_t ...\n", cmnd);
    exit(1);
}


int main(int argc, char **argv) {
    int i;
    char *format = "%Y-%m-%d %H:%M:%S %Z";
    int c;

    cmnd = argv[0];

    while ((c = getopt(argc, argv, "f:")) != EOF) {
	switch(c) {
	case 'f':
	    format = optarg;
	    break;
	case '?':
	    usage();
	default:
	    assert("this" == "unreachable");
	}
    }

    if (optind >= argc) usage();

    for (i = optind; i < argc; i++) {
	time_t t = strtoul(argv[i], NULL, 0);
	struct tm *tmp;
	char buf[1024];

	tmp = localtime(&t);
	strftime(buf, sizeof(buf), format, tmp);
	printf("%s\n", buf);
    }
    return 0;
}
/* vim:sw=4
 */

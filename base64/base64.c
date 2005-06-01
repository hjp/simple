#include <ant/base64.h>
#include <unistd.h>
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

char *cmnd;

static void usage(void) {
    fprintf(stderr, "Usage: %s [-d|-e]\n", cmnd);
    exit(1);
}

int main(int argc, char **argv) {
    char buf1[1024+1];
    char buf2[1024+1];
    enum { NONE, ENCODE, DECODE} mode = NONE;
    int c;
    int r1, r2;
    cmnd = argv[0];
    while ((c = getopt(argc, argv, "de")) != EOF) {
	switch(c) {
	    case 'd':
		mode = DECODE;
		break;
	    case 'e':
		mode = ENCODE;
		break;
	    case '?':
		usage();
	    default:
		assert(0);
	}
    }
    switch(mode) {
	case NONE:
	    usage();
	case ENCODE:
	    while ((r1 = fread(buf1, 1, 57, stdin)) > 0) {
		r2 = base64_encode(buf2, sizeof(buf2), buf1, r1, 76);
		fwrite(buf2, 1, r2, stdout);
		putchar('\n');
	    }
	    break;
	case DECODE:
	    while (fgets(buf1, sizeof(buf1), stdin)) {
		r1 = strlen(buf1);
		if (buf1[r1-1] == '\n') r1--;
		r2 = base64_decode(buf2, sizeof(buf2), buf1, r1);
		fwrite(buf2, 1, r2, stdout);
	    }
    }
    return 0;
}

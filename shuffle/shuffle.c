#include <assert.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <time.h>

#include <ant/io.h>
#include <ant/string.h>

char *cmnd;

char **lines;
int nr_lines;
int nr_lines_a;

unsigned int seed;

static void usage(void)
{
    fprintf(stderr, "Usage: %s [-s seed]\n", cmnd);
    exit(1);
}

static void readfile(const char *filename)
{
    FILE *fp;
    char *ln;

    if (STREQ(filename, "-")) {
        fp = stdin;
    } else {
        fp = efopen(filename, "r");
    }
    while ((ln = getline(fp))) {
        if (nr_lines >= nr_lines_a) {
            nr_lines_a = nr_lines_a * 3 / 2 + 1;
            assert (nr_lines_a > nr_lines);
            lines = realloc(lines, nr_lines_a * sizeof(*lines));
            assert(lines);
        }
        lines[nr_lines++] = strdup(ln);
    }
    if (fp != stdin) {
        fclose(fp);
    }
}


static void shuffle(void) {
    int i;
    int j;
    char *p;

    srand(seed);
    for (i = 0; i < nr_lines; i++) {
        j = rand() / ((double)RAND_MAX + 1) * nr_lines;
        assert (0 <= j && j < nr_lines);
        p = lines[i];
        lines[i] = lines[j];
        lines[j] = p;
    }
}


static void dump(void) {
    int i;

    for (i = 0; i < nr_lines; i++) {
        puts(lines[i]);
    }
}


int main(int argc, char **argv)
{
    int c;
    int i;
    char *p;

    cmnd = argv[0];

    seed = time(NULL);
    while ((c = getopt(argc, argv, "")) != EOF) {
	switch (c) {
	case 's':
            seed = strtoul(optarg, &p, 0);
            if (p == optarg || *p != '\0') usage();
            break;
	case '?':
	    usage();
	default:
	    assert(0);
	}
    }

    if (optind == argc) {
	readfile("-");
    }
    for (i = optind; i < argc; i++) {
	readfile(argv[i]);
    }
    shuffle();
    dump();
    return 0;
}

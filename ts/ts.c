#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <time.h>
#include <unistd.h>
#include <string.h>
#include <errno.h>

static char *cmnd;

static void usage(void) {
    fprintf(stderr, "Usage: %s [-u] [-s] [-r] [-o file]\n", cmnd);
    exit(1);
}


int main(int argc, char **argv) {
    int c;
    int use_microseconds = 0;
    int use_seconds = 0;
    int print_ts = 1;
    char lastfile[FILENAME_MAX] = "", file[FILENAME_MAX] = "";
    char *filepat = NULL;
    FILE *fp = NULL;
    struct timeval start = { 0, 0 };

    cmnd = argv[0];

    while ((c = getopt(argc, argv, "suro:")) != EOF) {
	switch (c) {
	    case 'u':
		use_microseconds = 1;
		break;
	    case 'o':
		filepat = optarg;
		break;
	    case 's':
		use_seconds = 1;
		break;
	    case 'r':
		gettimeofday(&start, NULL);
		use_seconds = 1;
		use_microseconds = 1;
		break;
	    default:
		usage();
	}
    }
    if (!filepat) {
	fp = stdout;
	setlinebuf(fp);
    }
    while ((c = getchar()) != EOF) {
	if (print_ts) {
	    struct timeval tv;
	    char s[sizeof("yyyy-mm-ddThh:mm:ss")];
	    gettimeofday(&tv, NULL);
	    if (filepat) {
		strftime(file, sizeof(file), filepat,
			 localtime(&tv.tv_sec));
		if (strcmp(lastfile, file) != 0) {
		    if (fp) {
			if (fclose(fp) == EOF) {
			    fprintf(stderr, "%s: cannot close %s: %s\n", argv[0], lastfile, strerror(errno));
			    exit(1);
			}
		    }
		    if ((fp = fopen(file, "a")) == NULL) {
			fprintf(stderr, "%s: cannot open %s: %s\n", argv[0], file, strerror(errno));
			exit(1);
		    }
		    setlinebuf(fp);
		    strcpy(lastfile, file);
		}
	    }

	    if (use_seconds) {
		tv.tv_usec -= start.tv_usec;
		if (tv.tv_usec < 0) {
		    tv.tv_usec += 1000000;
		    tv.tv_sec -= 1;
		}
		tv.tv_sec -= start.tv_sec;
		fprintf(fp, "%ld", (long)tv.tv_sec);
	    } else {
		strftime(s, sizeof(s), "%Y-%m-%dT%H:%M:%S",
			 localtime(&tv.tv_sec));
		fputs(s, fp);
	    }
	    if (use_microseconds) {
		fprintf(fp, ".%06ld ", (long)tv.tv_usec);
	    }
	    putc(' ', fp);
	    print_ts = 0;
	}
	putc(c, fp);
	if (c == '\n') print_ts = 1;
    }
    if (!print_ts) putc('\n', fp);	// force newline at end of output
    return 0;
}

char prwtmp_c_rcs_id[] = 
	"$Id: prwtmp.c,v 1.1 1997-01-13 14:59:40 hjp Exp $";
/*
 * prwtmp - print wtmp to stdout
 *
 * $Log: prwtmp.c,v $
 * Revision 1.1  1997-01-13 14:59:40  hjp
 * Checked into CVS.
 * Added -o and -s options.
 *
 */
#include <assert.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#include <sys/types.h>
#include <utmp.h>

char *cmnd;

void usage(void) {
	fprintf(stderr, "Usage: %s [-o] [-s start] [file]\n", cmnd);
	exit(1);
}


int main (int argc, char **argv) {
	FILE *fp;
	struct utmp u;
	char *filename = WTMP_FILE;
	long off;
	int print_offset = 0;
	int c;
	char *p;

	cmnd = argv[0];
	while ((c = getopt(argc, argv, "s:o")) != EOF) {
		switch(c) {
		case 's':
			off = strtoul(optarg, &p, 0);
			if (p == optarg || *p != '\0') usage();
			break;
		case 'o':
			print_offset = 1;
			break;
		case '?':
			usage();
		default:
			assert(0);
		}
	}

	if (argc > optind) filename = argv[optind];

	fp = fopen(filename, "rb");
	if (!fp) {
		fprintf(stderr, "%s: cannot open %s: %s\n",
			cmnd, filename, strerror(errno));
		exit(1);
	}
	if (fseek(fp, off, SEEK_SET) == -1) {
		fprintf(stderr, "%s: cannot seek to %ld on %s: %s\n",
			cmnd, off, filename, strerror(errno));
		exit(1);
	}
		
	while (fread(&u, (int)sizeof(u), 1, fp) == 1) {
		char tbuf[20];

		if (print_offset) printf ("%8ld: ", off);
		off += sizeof(u);

		strftime(tbuf, (int)sizeof(tbuf), "%Y-%m-%d %H:%M:%S",
		         localtime(&u.ut_time));
		printf("%s ", tbuf);
		printf("%-*.*s ",
		       (int)sizeof(u.ut_user),
		       (int)sizeof(u.ut_user),
		       u.ut_user);
		printf("%-*.*s ",
		       (int)sizeof(u.ut_id),
		       (int)sizeof(u.ut_id),
		       u.ut_id);
		printf("%-*.*s ",
		       (int)sizeof(u.ut_line),
		       (int)sizeof(u.ut_line),
		       u.ut_line);
		printf("%5d ", (int)u.ut_pid); /* PID is typically < 30000 */
		printf("%5d ", (int)u.ut_type); /* short on HP-UX */
		printf("%5d ", (int)u.ut_exit.e_termination); /* short on HP-UX */
		printf("%5d ", (int)u.ut_exit.e_exit); /* short on HP-UX */
		printf("%-*.*s ",
		       (int)sizeof(u.ut_host),
		       (int)sizeof(u.ut_host),
		       u.ut_host);
		printf("%08lx", u.ut_addr);
		printf("\n");
		
	}
	return 0;
}

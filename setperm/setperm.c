#include <assert.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <unistd.h>

char *cmnd;

static void usage(void) {
	fprintf(stderr, "Usage: %s -F protofile file ...\n", cmnd);
	exit(1);
}

typedef struct {
	uid_t user;
	gid_t group;
	mode_t mode;
} perm_t;

static int getperm(const char *filename, perm_t *permp) {
	struct stat sb;

	if (stat(filename, &sb) == -1) return -1;
	permp->user = sb.st_uid;
	permp->group = sb.st_gid;
	permp->mode = sb.st_mode;
	return 0;
}

static int setperm(const char *filename, perm_t perm) {
	int rc = 0;
	
	if (chown(filename, perm.user, perm.group) == -1) {
		fprintf (stderr, "%s: cannot change owner of `%s' to %ld:%ld: %s\n",
			 cmnd, filename, (long)perm.user, (long)perm.group, strerror(errno));
		rc = 1;
	}
	if (chmod(filename, perm.mode) == -1) {
		fprintf (stderr, "%s: cannot change mode of %s to %lo: %s\n",
			 cmnd, filename, (unsigned long)perm.mode, strerror(errno));
		rc = 1;
	}
	return rc;
}

int main (int argc, char **argv) {
	int c;
	perm_t perm;
	int i;

	cmnd = argv[0];

	while ((c = getopt(argc, argv, "o:g:m:F:R")) != EOF) {
		switch (c) {
		case 'o':
		case 'p':
		case 'm':
		case 'R':
			fprintf (stderr, "%s: option `%c' not yet implemented. Sorry\n", cmnd, c);
			exit(1);
		case 'F':
			if (getperm (optarg, &perm) == -1) {
				fprintf (stderr, "%s: cannot get permissions from %s: %s\n",
					cmnd, optarg, strerror(errno));
				exit(1);
			}
			break;
		case '?':
			usage ();
		default: 
			assert(0);
		}
	}
	for (i = optind; i < argc; i ++) {
		setperm(argv[i], perm);
	}
	return 0;
}

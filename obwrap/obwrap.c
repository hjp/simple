char obwrap_c_rcsid[] = 
	"$Id: ";
/* obwrap - wrapper for omniback scripts 
 *
 * Omniback leaves a lot of file descriptors open when executing its
 * pre- and post-backup scripts. This means that any program started
 * from such a script (e.g., oracle) will have open file descriptors
 * on /var/opt/omni, which is a bad thing.
 * This program closes all file descriptors except stdin and stdout,
 * changes uid (if -u is given) and executes the specified program.
 */
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <pwd.h>
#include <unistd.h>

#define nonstderr stdout	/* Omniback bogosity */

char *cmnd;

void usage(void) {
    fprintf(stderr, "Usage: %s [-u user] path arg0 ...\n", cmnd);
    exit(1);
}


int main(int argc, char **argv) {
    int i;
    int c;
    int open_max = sysconf(_SC_OPEN_MAX);

    cmnd = argv[0];

    while ((c = getopt(argc, argv, "u:")) != EOF) {
	switch (c) {
	    case 'u': {
		char *p;
		uid_t uid;
		gid_t gid;

		uid = strtol(optarg, &p, 0);
		if (*p != '\0') {
		    struct passwd *pwd = getpwnam(optarg);
		    if (!pwd) {
			fprintf(nonstderr, "%s: no user %s\n", cmnd, optarg);
			exit(1);
		    }
		    initgroups(optarg, pwd->pw_gid);
		    setresgid(pwd->pw_gid, pwd->pw_gid, pwd->pw_gid);
		    if (getgid() != pwd->pw_gid) {
			fprintf(nonstderr, "%s: could not set gid %d (still %d)\n", cmnd, pwd->pw_gid, getgid());
			exit(1);
		    }
		    if (getegid() != pwd->pw_gid) {
			fprintf(nonstderr, "%s: could not set egid %d (still %d)\n", cmnd, pwd->pw_gid, getgid());
			exit(1);
		    }
		    uid = pwd->pw_uid;
			
		}
		setresuid(uid, uid, uid);
		if (getuid() != uid) {
		    fprintf(nonstderr, "%s: could not set uid %d (still %d)\n", cmnd, uid, getuid());
		    exit(1);
		}
		if (geteuid() != uid) {
		    fprintf(nonstderr, "%s: could not set euid %d (still %d)\n", cmnd, uid, geteuid());
		    exit(1);
		}
		break;
	    }
	    default:
		usage();
		
	}
    }
    if (optind == argc) usage();

    for (i = 2; i < open_max; i++) {
	close(i);
    }

    dup2(1, 2);

    execv(argv[optind], argv + optind + 1);
    fprintf(nonstderr, "%s: could not exec %s: %s\n",
    		cmnd, argv[optind], strerror(errno));
    exit(1);


    return 0;
}

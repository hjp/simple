char ddm_c_rcs_id[] =
    "$Id: ddm.c,v 1.3 2000-06-04 16:19:00 hjp Exp $";
/* 
 * ddm - disk delay monitor
 *
 * chdirs to a list of filesystems (mount points by default) and does
 * the equivalent of an ls -l.
 */

#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <dirent.h>
#include <mntent.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <unistd.h>

#include <ant/da.h>

#include "cfg/mnttab.h"

static double gettimestamp(void) {
    struct timeval tm;

    gettimeofday(&tm, NULL);
    return tm.tv_sec + tm.tv_usec/1E6;
}

int main(int argc, char**argv) {
    char **dirs = NULL;
    char **entries = NULL;

    for (;;) {
	FILE *mtp;
	struct mntent *me;
	double ts; 
	int i;
	int nr_dirs;
	int sleeptime;

	/* Get list of directories 
	 */
	ts = gettimestamp();
	fprintf(stderr, "%s: %.6f: open %s\n", argv[0], ts, MNTTAB);
	if ((mtp = setmntent(MNTTAB, "r")) == NULL) {
	    fprintf(stderr, "%s: cannot open %s: %s\n",
		    argv[0], MNTTAB, strerror(errno));
	    exit(1);
	}
	for (i = 0;(me = getmntent(mtp)); i++) {
	    DA_MKIND_INI(dirs, i, NULL);
	    if (dirs[i]) free(dirs[i]);
	    dirs[i] = strdup(me->mnt_dir);
	    ts = gettimestamp();
	    fprintf(stderr, "%s: %.6f: mountpoint %s\n",
		    argv[0], ts, dirs[i]);
	}
	endmntent(mtp);

	nr_dirs = i;

	/* Now read them
	 */
	for (i = 0; i < nr_dirs; i++) {
	    int j;
	    int nr_entries;
	    DIR *dp;
	    struct dirent *de;

	    fprintf(stderr, "%s: %.6f: start %s\n",
		    argv[0], gettimestamp(), dirs[i]);
	    if (chdir(dirs[i]) == -1) {
		fprintf(stderr, "%s: %.6f: chdir %s failed: %s\n",
			argv[0], gettimestamp(), dirs[i], strerror(errno));
		break;
	    }
	    fprintf(stderr, "%s: %.6f: chdir %s ok\n",
		    argv[0], gettimestamp(), dirs[i]);

	    if ((dp = opendir(".")) == NULL) {
		fprintf(stderr, "%s: %.6f: opendir %s failed: %s\n",
			argv[0], gettimestamp(), dirs[i], strerror(errno));
		break;
	    }
	    for (j = 0;(de = readdir(dp)); j++) {
		DA_MKIND_INI(entries, j, NULL);
		if (entries[j]) free(entries[j]);
		entries[j] = strdup(de->d_name);
		fprintf(stderr, "%s: %.6f: entry %s\n",
			argv[0], gettimestamp(), entries[j]);
	    }
	    closedir(dp);
	    nr_entries = j;

	    for (j = 0; j < nr_entries; j++) {
		struct stat st;
		stat (entries[j], &st);
		fprintf(stderr, "%s: %.6f: stat entry %s\n",
			argv[0], gettimestamp(), entries[j]);
	    }
	}

	sleeptime = rand() * 60.0 / RAND_MAX;
	fprintf(stderr, "%s: %.6f: sleeping %d seconds\n",
		argv[0], gettimestamp(), sleeptime);
	sleep(sleeptime);
    }
	    
	
    return 0;
}

/* 
 * $Log: ddm.c,v $
 * Revision 1.3  2000-06-04 16:19:00  hjp
 * Fixed order of args in fprintf (segfault).
 *
 * Revision 1.2  2000/06/04 16:11:12  hjp
 * Added autodetection of /etc/m(nt)?tab.
 *
 * Revision 1.1  2000/06/04 15:53:19  hjp
 * Pre-Version. Options are still missing.
 *
 */

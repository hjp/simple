char ddm_c_rcs_id[] =
    "$Id: ddm.c,v 1.6 2001-02-21 16:02:46 hjp Exp $";
/* 
 * ddm - disk delay monitor
 *
 * chdirs to a list of filesystems (mount points by default) and does
 * the equivalent of an ls -l.
 */

#include <assert.h>
#include <errno.h>
#include <stdio.h>
#include <stdarg.h>
#include <stdlib.h>
#include <string.h>

#include <dirent.h>
#include <mntent.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <unistd.h>

#include <ant/da.h>
#include <ant/io.h>
#include <ant/globals.h>

#include "cfg/mnttab.h"


typedef enum { MODE_NONE, MODE_ARGS, MODE_MNTTAB, MODE_DIRFILE } modeT;


static double gettimestamp(void) {
    struct timeval tm;

    gettimeofday(&tm, NULL);
    return tm.tv_sec + tm.tv_usec/1E6;
}

static void usage(void) {
    fprintf(stderr, "Usage: %s [-d dirfile | -m mnttab | directory ...  ] [-s max_sleep_time]\n",
	    cmnd);
    exit(1);
}

void printtimestamp (const char *fmt, ...) {
    static double lts = 0;
    double ts = gettimestamp();
    va_list ap;

    fprintf(stderr, "%s: %.6f: %.6f: ", cmnd, ts, ts - lts);
    va_start(ap, fmt);
    vfprintf(stderr, fmt, ap);
    va_end(ap);
    lts = ts;
}

int main(int argc, char**argv) {
    char **dirs = NULL;
    modeT mode = MODE_NONE;
    int nr_dirs;
    int c;
    char *filename = NULL;
    double maxsleeptime = 3600;

    cmnd = argv[0];

    while ((c = getopt(argc, argv, "d:m:s:")) != EOF) {
	switch (c) {
	    char *p;

	    case 'd':
		mode = MODE_DIRFILE;
		filename = optarg;
		break;
	    case 'm':
		mode = MODE_MNTTAB;
		filename = optarg;
		break;
	    case 's':
		maxsleeptime = strtod(optarg, &p);
		if (p == optarg || *p) usage();
		break;
	    case '?':
		usage();
	    default:
		assert(0);
	}
    }

    if (mode == MODE_NONE) {
	if (optind == argc) {
	    mode = MODE_MNTTAB;
	    filename = PATH_MNTTAB;
	} else {
	    mode = MODE_ARGS;
	    dirs = argv + optind;
	    nr_dirs = argc - optind;
	}
    } else {
	if (optind != argc) usage();
    }


    srand(time(NULL));

    for (;;) {
	int i;
	int sleeptime;

	/* Get list of directories 
	 */
	switch (mode) {
	    case MODE_MNTTAB: {
		FILE *mtp;
		struct mntent *me;

		printtimestamp("open %s\n", filename);
		if ((mtp = setmntent(filename, "r")) == NULL) {
		    fprintf(stderr, "%s: cannot open %s: %s\n",
			    argv[0], filename, strerror(errno));
		    exit(1);
		}
		for (i = 0;(me = getmntent(mtp)); i++) {
		    DA_MKIND_INI(dirs, i, NULL);
		    if (dirs[i]) free(dirs[i]);
		    dirs[i] = strdup(me->mnt_dir);
		    printtimestamp("mountpoint %s\n", dirs[i]);
		}
		endmntent(mtp);

		nr_dirs = i;
		break;
	    }
	    case MODE_DIRFILE: {
		FILE *fp;
		char *p;

		printtimestamp("open %s\n", filename);
		fp = efopen(filename, "r");
		for (i = 0;(p = getline(fp)); i++) {
		    DA_MKIND_INI(dirs, i, NULL);
		    if (dirs[i]) free(dirs[i]);
		    dirs[i] = strdup(p);
		    printtimestamp("directory %s\n", dirs[i]);
		}
		efclose(fp);

		nr_dirs = i;
		break;
	    }
	    case MODE_ARGS:
		break;
	    default:
		assert(0);
	}


	/* Now read them
	 */
	for (i = 0; i < nr_dirs; i++) {
	    int j;
	    char **entries = NULL;
	    int nr_entries;
	    DIR *dp;
	    struct dirent *de;

	    printtimestamp("start %s\n", dirs[i]);
	    if (chdir(dirs[i]) == -1) {
		printtimestamp("chdir %s failed: %s\n", dirs[i], strerror(errno));
		continue;
	    }
	    printtimestamp("chdir %s ok\n", dirs[i]);

	    if ((dp = opendir(".")) == NULL) {
		printtimestamp("opendir %s failed: %s\n", dirs[i], strerror(errno));
		continue;
	    }
	    for (j = 0;(de = readdir(dp)); j++) {
		DA_MKIND_INI(entries, j, NULL);
		if (entries[j]) free(entries[j]);
		entries[j] = strdup(de->d_name);
		printtimestamp("entry %s\n", entries[j]);
	    }
	    closedir(dp);
	    nr_entries = j;

	    for (j = 0; j < nr_entries; j++) {
		struct stat st;
		stat (entries[j], &st);
		printtimestamp("stat entry %s\n", entries[j]);
	    }
	}

	chdir("/");

	sleeptime = rand() * maxsleeptime / RAND_MAX;
	printtimestamp("sleeping %d seconds\n", sleeptime);
	sleep(sleeptime);
    }
	    
	
    return 0;
}

/* 
 * $Log: ddm.c,v $
 * Revision 1.6  2001-02-21 16:02:46  hjp
 * Added config test for mnttab again.
 * Added option -s (max sleep time)
 * Added script stats.sh to generate stats.
 *
 * Revision 1.5  2000/09/07 10:12:35  hjp
 * Added alternate ways to specify directories to be monitored.
 *
 * Revision 1.4  2000/06/04 16:33:21  hjp
 * Removed MNTTAB autodetection again as it seems to be already defined.
 * Don't skip rest of mountpoints if one is not accessible.
 * chdir to / while sleeping to avoid blocking automounters
 * increased default sleep interval to 1 hour max.
 *
 * Revision 1.3  2000/06/04 16:19:00  hjp
 * Fixed order of args in fprintf (segfault).
 *
 * Revision 1.2  2000/06/04 16:11:12  hjp
 * Added autodetection of /etc/m(nt)?tab.
 *
 * Revision 1.1  2000/06/04 15:53:19  hjp
 * Pre-Version. Options are still missing.
 *
 */

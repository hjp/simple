/*
 *	Fortune -- Print one fortune out of an indexed fortune file
 */

static char fortune_c_rcsid[] = "$Id: fortune.c,v 3.3 1992-03-24 11:15:45 hjp Exp $";

#include <errno.h>
#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#include <sys/types.h>
#include <sys/stat.h>

#include <ant/io.h>
#include <ant/string.h>

/*	The following parameters will have to be adapted to your system	*/
#define DELIMITER	"%%\n"
#define MAXLINE		(80 + 1 + 1)
char * fortunefile	= "/usr/lib/fortune.dat";
char indexfile [PATH_MAX] = "/usr/lib/fortune.idx";
/*	The rest should be generic	*/

	int
main(
	int argc,
	char **argv
){
	FILE 		* ffp, * ifp;
	char		* p;
	long		pos,
			cnt,		/* Number of fortunes in the file
					 */
			nr,		/* number of fortune to read	*/
			fortune_time;	/* time the fortune file was last
					 * updated.
					 */
	struct stat	statbuf;
	char		line [MAXLINE];

	if (argc >= 2){
		fortunefile = argv [1];
		strncpy (indexfile, argv [1], PATH_MAX);
		if (p = strrchr (indexfile, '.')) {
			strcpy (p, ".idx");
		} else {
			strcat (indexfile, ".idx");
		}
	}
#ifdef DEBUG
	printf ("fortunefile = \"%s\"\n", fortunefile);
	printf ("indexfile   = \"%s\"\n", indexfile);
#endif /* DEBUG */

	/*	First check if index file is younger than fortune file
	 *	and rebuild it if necessary.
	 */

	if (stat (fortunefile, &statbuf) < 0) {
		eprintf ("%s: Cannot stat \"%s\": %s",
			argv [0], fortunefile, strerror (errno));
		exit (1);
	}
	fortune_time = statbuf.st_mtime;
	if (stat (indexfile, &statbuf) < 0) {
		/*	Index file does not exit -- force its creation
		 *	and pretend it is older than fortune file
		 */

		if ((ifp = fopen (indexfile, "wb")) == NULL) {
			eprintf ("%s: Cannot fopen \"%s\": %s",
				argv [0], indexfile, strerror (errno));
			exit (3);
		}
		fclose (ifp);
		statbuf.st_mtime = 0;
	}
	if (statbuf.st_mtime < fortune_time) {
		/*	Index file does either not exist or is older
		 *	than fortune file.
		 */

		if ((ffp = fopen (fortunefile, "r")) == NULL) {
			eprintf ("%s: Cannot fopen \"%s\": %s",
				argv [0], fortunefile, strerror (errno));
			exit (2);
		}
		if ((ifp = fopen (indexfile, "r+b")) == NULL) {
			eprintf ("%s: Cannot fopen \"%s\": %s",
				argv [0], indexfile, strerror (errno));
			exit (3);
		}
		cnt = 0;
		fwrite (&cnt, sizeof (long), 1, ifp);
		fseek (ifp, sizeof (long), SEEK_CUR); /* leave position	intact */
		while (fgets (line, sizeof (line), ffp)) {
			if (STREQ (line, DELIMITER)) {
				pos = ftell (ffp);
				fwrite (&pos, sizeof (long), 1, ifp);
				++ cnt;
			}
		}
		fseek (ifp, 0, SEEK_SET);
		fwrite (&cnt, sizeof (long), 1, ifp);
		fclose (ifp);
		fclose (ffp);
	}

	/* Now that we have a valid index file, open it and choose a fortune
	 */

	if ((ifp = fopen (indexfile, "r+b")) == NULL) {
		eprintf ("%s: Cannot fopen \"%s\": %s",
			argv [0], indexfile, strerror (errno));
		exit (4);
	}

	if ((ffp = fopen (fortunefile, "r")) == NULL) {
		eprintf ("%s: Cannot fopen \"%s\": %s",
			argv [0], fortunefile, strerror (errno));
		exit (5);
	}

	/*	Get number of entries	*/
	fread (&cnt, sizeof (long), 1, ifp);

	if (cnt == 0) {
		eprintf ("%s: empty fortune file\n", argv [0]);
		exit (6);
	}

	fseek (ifp, sizeof (long), SEEK_SET);
	fread (&nr, sizeof (long), 1, ifp);
	nr ++;
	if (nr >= cnt) nr = 0;
	fseek (ifp, sizeof (long), SEEK_SET);
	fwrite (&nr, sizeof (long), 1, ifp);

	/* Now look for the start of the fortune in the index file	*/
	fseek (ifp, (nr + 2) * sizeof (long), SEEK_SET);
	fread (&pos, sizeof (long), 1, ifp);

	/* And seek to it in the fortune file	*/
	fseek (ffp, pos, SEEK_SET);

	/* write one fortune	*/
	while (fgets (line, sizeof (line), ffp) && ! STREQ (line, DELIMITER)) {
		fputs (line, stdout);
	}
	fclose (ifp);
	fclose (ffp);
	return 0;
}

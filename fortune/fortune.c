/*
 *	Fortune -- Print one fortune out of an indexed fortune file
 */

static char fortune_c_rcsid[] = "$Id: fortune.c,v 3.4 1994-01-08 18:05:00 hjp Exp $";

#include <assert.h>
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
#include <ant/globals.h>

/*	The following parameters will have to be adapted to your system	*/
#define DELIMITER	"%%\n"
#define MAXLINE		(80 + 1 + 1)
char * fortunefile	= "/usr/lib/fortune.dat";
char indexfile [PATH_MAX] = "/usr/lib/fortune.idx";
#define RECLEN		4	/* length of a record in the index
				 * file. This would normally be the 
				 * size of a long, but could be more
				 * or less if you want the program
				 * run on systems with different lengths
				 * of a long and share the same index
				 * file.
				 */
/*	The rest should be generic	*/



void fwritelong (FILE *fp, long offset, long value) {
	unsigned char c [RECLEN];

	assert (value < (1UL << (8 * RECLEN - 1)));

	if (fseek (fp, offset, SEEK_SET) != 0) {
		eprintf ("%s: cannot seek to %ld in %s: %s\n",
			 cmnd, offset, indexfile, strerror (errno));
		exit (1);
	}

	c [0] = value & 0xFF;
	c [1] = (value >> 8) & 0xFF;
	c [2] = (value >> 16) & 0xFF;
	c [3] = (value >> 24) & 0xFF;

	if (fwrite (c, RECLEN, 1, fp) != 1) {
		eprintf ("%s: cannot write to %s: %s\n",
			 cmnd, indexfile, strerror (errno));
		exit (1);
	}
}

long freadlong (FILE *fp, long offset) {
	unsigned char	c [RECLEN];
	unsigned long	value;

	if (fseek (fp, offset, SEEK_SET) != 0) {
		eprintf ("%s: cannot seek to %ld in %s: %s\n",
			 cmnd, offset, indexfile, strerror (errno));
		exit (1);
	}

	if (fread (c, RECLEN, 1, fp) != 1) {
		eprintf ("%s: cannot write to %s: %s\n",
			 cmnd, indexfile, strerror (errno));
		exit (1);
	}

	value = c [0] + (c [1] << 8) + (c [2] << 16) + (c [3] << 24);
	return value > LONG_MAX ? - (long) (- value) : value;
}


	int
main(
	int argc,
	char **argv
){
	FILE 		* ffp, * ifp;
	char		* p;
	long		pos, ipos,	/* position in fortune and
					 * index file 
					 */
			cnt,		/* Number of fortunes in the file
					 */
			nr,		/* number of fortune to read	*/
			fortune_time;	/* time the fortune file was last
					 * updated.
					 */
	struct stat	statbuf;
	char		line [MAXLINE];

	cmnd = argv [0];

	if (argc >= 2){
		fortunefile = argv [1];
		strncpy (indexfile, argv [1], PATH_MAX);
		if ((p = strrchr (indexfile, '.'))) {
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
		fwritelong (ifp, 0, cnt);
		ipos = RECLEN * 2;
		while (fgets (line, sizeof (line), ffp)) {
			if (STREQ (line, DELIMITER)) {
				pos = ftell (ffp);
				fwritelong (ifp, ipos, pos);
				++ cnt;
				ipos += RECLEN;
			}
		}
		fwritelong (ifp, 0, cnt);
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
	cnt = freadlong (ifp, 0);

	if (cnt == 0) {
		eprintf ("%s: empty fortune file\n", argv [0]);
		exit (6);
	}

	nr = freadlong (ifp, RECLEN);
	nr ++;
	if (nr >= cnt) nr = 0;
	fwritelong (ifp, RECLEN, nr);

	/* Now look for the start of the fortune in the index file	*/
	pos = freadlong (ifp, (nr + 2) * RECLEN);

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

char fix2var_c_rcs_id[] = 
	"$Id: fix2var.c,v 1.1 1996-08-30 12:25:22 hjp Exp $";
/* 
 * fix2var - convert fixed length record data to line oriented format
 *
 * This program simply copies fixed length chunks from a file to 
 * stdout. Each chunk is terminated with a '\n' character. 
 * Optionally trailing white space can be stripped.
 *
 * $Log: fix2var.c,v $
 * Revision 1.1  1996-08-30 12:25:22  hjp
 * Initial release.
 *
 */
#include <assert.h>
#include <ctype.h>
#include <limits.h>
#include <stdio.h>
#include <ant/io.h>
#include <ant/alloc.h>

char *cmnd;

unsigned long width = 80;
int strip = 1;

void usage(void) {
    fprintf(stderr, "Usage: %s [-l width] [file ...]\n", cmnd);
    exit(1);
}


void fix2var(const char *filename) {
    FILE *fp;
    char *buf = emalloc(width+1);
    size_t rc;
    int i;

    if (strcmp(filename, "-") == 0) {
    	fp = stdin;
    } else {
	fp = efopen(filename, "r");
    }
    while ((rc = fread (buf, 1, width, fp)) != 0 && (rc != (size_t)-1)) {
	if (rc < width) {
	    fprintf(stderr, "%s: warning: short record (%lu bytes)"
		    " encountered\n", cmnd, (unsigned long)rc);
	}
	assert (rc <= INT_MAX);
	if (strip) {
	    for (i = rc - 1; i >= 0 && isspace(buf[i]); i--);
	    buf[i+1] = '\0';
	} else {
	    buf[rc] = '\0';
	}
	puts(buf);
    }

    fclose(fp);
    free(buf);
}


int main(int argc, char **argv) {
    int c;
    int i;
    char *p;

    cmnd = argv[0];

    while ((c = getopt(argc, argv, "sw:")) != EOF) {
	switch (c) {
	    case 's':
		strip= 1;
		break;
	    case 'w':
		width= strtoul(optarg, &p, 0);
		if (width == 0 || *p) usage();
		break;
	    case '?':
	    	usage();
	    default:
		assert(0);
	}
    }
    if (optind == argc) {
    	fix2var("-");
    } else {
	for (i = optind; i < argc; i++) {
	    fix2var(argv[i]);
	}
    }
    return 0;
}

char ftcp_rcs_id[] = 
    "$Id: ftcp.c,v 1.1 2002-03-18 20:40:08 hjp Exp $";
/* 
    ftcp - fault tolerant copy

    copy one file to another, ignoring any errors.
    This is useful for copying files from defective media.
 */
#include <assert.h>
#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <time.h>
#include <unistd.h>

#include <ant/io.h>
#include <ant/string.h>

char *cmnd;


off_t skip_size = 512;
size_t buf_size = 512;

static void usage(void)
{
    fprintf(stderr, "Usage: %s [-s skip_size] source dest\n", cmnd);
    exit(1);
}


static int ftcp(char const *src, char const *dest)
{
  int sfd, dfd, count;
  char *buf;
  off_t off = 0;

  if ((buf = malloc(buf_size)) == NULL) {
    return -1;
  }
  sfd = open(src, O_RDONLY);
  if (sfd < 0)
    return -1;
  dfd = open(dest, O_WRONLY|O_CREAT|O_TRUNC, 0666);
  if (dfd < 0)
  {
    close(sfd);
    return -1;
  }
  for (;;) {
    lseek(sfd, off, SEEK_SET);
    count = read(sfd, buf, buf_size);
    switch (count) {
	case -1:
	    fprintf(stderr, "%s: error at offset %lu: %s\n",
	    	    cmnd, (unsigned long)off, strerror(errno));
	    off += skip_size;
	    break;
	case 0:
	    goto the_end;
	default:
	    lseek(dfd, off, SEEK_SET);
	    write(dfd, buf, count);
	    off += count;
    }
  }
  the_end:
	    
  close(sfd);
  close(dfd);
  return 0;
}



int main(int argc, char **argv)
{
    int c;
    char *p;

    cmnd = argv[0];

    while ((c = getopt(argc, argv, "s:")) != EOF) {
	switch (c) {
	case 's':
            skip_size = strtoul(optarg, &p, 0);
            if (p == optarg || *p != '\0') usage();
            break;
	case '?':
	    usage();
	default:
	    assert(0);
	}
    }

    if (optind != argc - 2) {
	usage();
    }
    ftcp(argv[optind], argv[optind+1]);
    return 0;
}

#define _GNU_SOURCE 1
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdlib.h>

struct {
    int mode;
    char *name;
} modes[] = {
    { O_APPEND, "O_APPEND" },
    { O_ASYNC, "O_ASYNC" },
    { O_CLOEXEC, "O_CLOEXEC" },
    { O_CREAT, "O_CREAT" },
    { O_DIRECT, "O_DIRECT" },
    { O_DIRECTORY, "O_DIRECTORY" },
    { O_EXCL, "O_EXCL" },
    { O_LARGEFILE, "O_LARGEFILE" },
    { O_NOATIME, "O_NOATIME" },
    { O_NOCTTY, "O_NOCTTY" },
    { O_NOFOLLOW, "O_NOFOLLOW" },
    { O_NONBLOCK, "O_NONBLOCK" },
    { O_NDELAY, "O_NDELAY" },
    { O_SYNC, "O_SYNC" },
    { O_TRUNC, "O_TRUNC" },
};
void dump_mode(int mode) {
    if ((mode & 3) == O_RDONLY) {
	printf("%7o %s\n", O_RDONLY, "O_RDONLY");
    } else
    if ((mode & 3) == O_WRONLY) {
	printf("%7o %s\n", O_WRONLY, "O_WRONLY");
    } else
    if ((mode & 3) == O_RDWR) {
	printf("%7o %s\n", O_RDWR, "O_RDWR");
    } else {
	printf("%7o %s\n", (mode & 3), "none");
    }

    for (int i = 0; i < sizeof(modes)/sizeof(modes[0]); i++) {
	if (modes[i].mode & mode) {
	    printf("%7o %s\n", modes[i].mode, modes[i].name);
	}
    }
    printf("\n");
}

int main(int argc, char **argv) {
    if (argc == 1) {
	dump_mode(-1);
    } else {
	for (char **arg = argv+1; *arg; arg++) {
	    int mode = strtoul(*arg, NULL, 0);
	    dump_mode(mode);
	}
    }
}

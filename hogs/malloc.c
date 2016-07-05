#include <stdlib.h>
#include <stdio.h>

int main(int argc, char **argv) {
    size_t size = strtoul(argv[1], NULL, 0);
    char *p = malloc(size);
    printf("%zu bytes at %p\n", size, p);
    sleep(10);
    return 0;
}

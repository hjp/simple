#include <ctype.h>
#include <locale.h>
#include <stdio.h>
#include <limits.h>

long hist[UCHAR_MAX+1];

int main (int argc, char **argv) {
    int c;

    setlocale(LC_ALL, "");
    while ((c = getchar()) != EOF) {
	hist[c]++;
    }
    for (c = 0; c <= UCHAR_MAX; c++) {
	if (hist[c]) {
	    printf ("%x %d %o %c\t%ld\n", c, c, c, isprint(c) ? c : '.', hist[c]);
	}
    }
    return 0;
}

#include <ctype.h>
#include <locale.h>
#include <limits.h>
#include <stdio.h>

int main(int argc, char **argv) {
    int i;

    setlocale(LC_ALL, "");

    for (i = 0; i <= UCHAR_MAX; i++) {
	printf ("%2x: ", i);
	printf("%c ", isprint(i) ? i : '.');
	printf("\n");
    }
    return 0;
}

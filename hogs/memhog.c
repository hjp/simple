#include <stdlib.h>
#include <stdio.h>
int main(void) {
        size_t s = 0x100000;
	size_t sum = 0;

        while (s) {
                void *p;
                if (p = malloc(s)) {
			sum += s;
                        printf("%lu - %lu\n",
			       (unsigned long)s,
			       (unsigned long)sum);
                        sleep (1);
                        memset(p, 'a', s);
			s *= 2;
                } else {
                        s /= 2;
                }
        }
        return 0;
}

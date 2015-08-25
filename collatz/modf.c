#include <stdio.h>
#include <math.h>

int main(void) {
    double x = 3.14;
    double y, z;

    y = modf(x, &z);
    printf("%g, %g\n", y, z);

    y = modf(x, NULL);
    printf("%g, %g\n", y, z);

    return 0;
}

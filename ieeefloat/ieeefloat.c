char ieeefloat_c_rcs_id[] = 
    "$Id: ieeefloat.c,v 1.1 1998-03-20 20:09:53 hjp Exp $";
/* ieeefloat: print binary representations of IEEE 754 FP numbers.
 *
 * $Log: ieeefloat.c,v $
 * Revision 1.1  1998-03-20 20:09:53  hjp
 * Initial release:
 * prints arguments as strings, floats, and doubles decimal and binary.
 *
 */
#include <assert.h>
#include <limits.h>
#include <stdio.h>
#include <stdlib.h>


#define BITS_FLT 32
#define EXC_FLT 127
#define MANT_FLT 23
#define SIGN_FLT ((floatint)1<<(BITS_FLT-1))

#define BITS_DBL 64
#define EXC_DBL 1023
#define MANT_DBL 52
#define SIGN_DBL ((doubleint)1<<(BITS_DBL-1))

#if ULONG_MAX/2+1 == (1UL << (BITS_FLT-1)) 
typedef unsigned long int floatint;
#elif UINT_MAX/2+1 == (1U << (BITS_FLT-1))
typedef unsigned int floatint;
#else
#error "no integral type with BITS_FLT bits"
#endif

#if ULONG_MAX/2+1 == (1UL << (BITS_DBL-1))
typedef unsigned long int doubleint;
#else
/* We cannot portably test for the existance of long long.
 * If it doesn't exist, either the compiler or sanitychecks
 * will complain
 */
typedef unsigned long long int doubleint;
#endif




char *cmnd;


static void usage(void) {
    fprintf(stderr, "Usage: %s fp-number ...\n", cmnd);
    exit(1);
}


static void printbinary (doubleint b, int d) {
    while (--d >= 0) {
	putchar('0' + ((b >> d) & 1));
    }
}


static void printfloat(float f) {
    union {
	floatint i;
	float f;
    } u;
    floatint e;
    floatint m;

    u.f = f;

    printf("%24.7g: ", f);
    printf("%c ", (u.i & SIGN_FLT) ? '-' : '+');
    u.i &= ~SIGN_FLT;
    e = u.i >> MANT_FLT;
    printf("   ");
    printbinary(e, BITS_FLT-1-MANT_FLT);

    m = (u.i & (((floatint)1 << MANT_FLT) - 1));
    if (e == 0) {	/* denormalized */
	printf(" [0.]");
    } else {
	printf(" [1.]");
    }
    printbinary(m, MANT_FLT);
    printf("\n");
}


static void printdouble(double f) {
    union {
	doubleint i;
	double f;
    } u;
    doubleint e;
    doubleint m;

    u.f = f;

    printf("%24.17g: ", f);
    printf("%c ", (u.i & SIGN_DBL) ? '-' : '+');
    u.i &= ~SIGN_DBL;
    e = u.i >> MANT_DBL;
    printbinary(e, BITS_DBL-1-MANT_DBL);

    m = (u.i & (((doubleint)1 << MANT_DBL) - 1));
    if (e == 0) {
	printf(" [0.]");
    } else {
	printf(" [1.]");
    }
    printbinary(m, MANT_DBL);
    printf("\n");
}


static void sanitychecks(void) {
    union {
	floatint i;
	float f;
    } fu;
    union {
	doubleint i;
	double f;
    } du;

    /* size */
    assert (sizeof(floatint) == sizeof(float));
    assert (sizeof(doubleint) == sizeof(double));

    /* some numbers */
    fu.f = 0;
    assert (fu.i == 0);
    du.f = 0;
    assert (du.i == 0);

    fu.f = 1.0;
    assert (fu.i == (floatint)(0 + EXC_FLT) << MANT_FLT);
    du.f = 1.0;
    assert (du.i == (doubleint)(0 + EXC_DBL) << MANT_DBL);

    fu.f = 1.5;
    assert (fu.i ==
            (((floatint)(0 + EXC_FLT) << MANT_FLT) | (1 << (MANT_FLT-1))));
    du.f = 1.5;
    assert (du.i == 
            (((doubleint)(0 + EXC_DBL) << MANT_DBL) | ((doubleint)1 << (MANT_DBL-1))));
}


int main(int argc, char**argv) {
    int i;

    cmnd = argv[0];
    sanitychecks();

    for (i = 1; i < argc; i++) {
	double d = strtod(argv[i], NULL);
	printf("%s\n", argv[i]);
	printdouble(d);
	printfloat(d);
    }

    return 0;
}

#include "cfg/have_hstrerror.h"
#include "hstrerror.h"

#if (!HAVE_HSTRERROR)
const char *hstrerror(int err) {
    static char errstr[80];

    snprintf(errstr, sizeof(errstr), "resolver error %d", err);
    return errstr;
}
#endif

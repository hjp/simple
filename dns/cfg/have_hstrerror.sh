cat > has_hstrerror_$$.c <<EOF
#include <netdb.h>
int main(void) { hstrerror(0); }
EOF
if $CC $CFLAGS has_hstrerror_$$.c $LDFLAGS -o has_hstrerror_$$
then
	echo '#define HAVE_HSTRERROR 1'
else 
	echo '#define HAVE_HSTRERROR 0'
fi
rm has_hstrerror_$$.c has_hstrerror_$$

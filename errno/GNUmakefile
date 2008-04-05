# $Id: GNUmakefile,v 1.4 2008-04-05 10:04:53 hjp Exp $
# $Log: GNUmakefile,v $
# Revision 1.4  2008-04-05 10:04:53  hjp
# added GNUmake*.sh
#
# Revision 1.3  2003/02/14 11:59:43  hjp
# Added list of #defines from HP-UX.
#
# Revision 1.2  1998/05/31 01:20:06  hjp
# GNUmakerules split into GNUmakerules and GNUmakevars.
#

include GNUmakevars

all: errno

errno: errno.o errno_list.o
errno_list.c: errno.list make_errno_list
	./make_errno_list

clean:
	rm errno

GNUmakevars: GNUmakevars.sh
	sh ./$^ > $@
GNUmakerules: GNUmakerules.sh
	sh ./$^ > $@

install: $(BINDIR)/errno

include GNUmakerules

# $Id: GNUmakefile,v 1.2 2000-06-04 16:11:12 hjp Exp $

include GNUmakevars

ddm: ddm.o
	$(CC) $^ $(ANTLIB) -o $@

ddm.o: ddm.c cfg/mnttab.h

clean:
	rm ddm ddm.o

install: $(SBINDIR)/ddm

cfg/%.h: cfg/%.sh
	sh $< > $@

include GNUmakerules

-include ddm.d

# $Log: GNUmakefile,v $
# Revision 1.2  2000-06-04 16:11:12  hjp
# Added autodetection of /etc/m(nt)?tab.
#
# Revision 1.1  2000/06/04 15:53:18  hjp
# Pre-Version. Options are still missing.
#

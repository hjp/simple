# $Id: GNUmakefile,v 1.4 2002-03-18 20:49:54 hjp Exp $

include GNUmakevars

ddm: ddm.o
	$(CC) $^ $(ANTLIB) -o $@

ddm.o: ddm.c

clean:
	rm -f ddm ddm.o

distclean: clean
	rm -f cfg/mnttab.h

install: $(SBINDIR)/ddm

cfg/%.h: cfg/%.sh
	sh $< > $@

include GNUmakerules

-include ddm.d

# $Log: GNUmakefile,v $
# Revision 1.4  2002-03-18 20:49:54  hjp
# Added target distclean
#
# Revision 1.3  2000/06/04 16:33:20  hjp
# Removed MNTTAB autodetection again as it seems to be already defined.
# Don't skip rest of mountpoints if one is not accessible.
# chdir to / while sleeping to avoid blocking automounters
# increased default sleep interval to 1 hour max.
#
# Revision 1.2  2000/06/04 16:11:12  hjp
# Added autodetection of /etc/m(nt)?tab.
#
# Revision 1.1  2000/06/04 15:53:18  hjp
# Pre-Version. Options are still missing.
#

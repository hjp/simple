# $Id: GNUmakefile,v 1.1 2000-06-04 15:53:18 hjp Exp $

include GNUmakevars

ddm: ddm.o
	$(CC) $^ $(ANTLIB) -o $@

clean:
	rm ddm ddm.o

install: $(SBINDIR)/ddm

include GNUmakerules

-include ddm.d

# $Log: GNUmakefile,v $
# Revision 1.1  2000-06-04 15:53:18  hjp
# Pre-Version. Options are still missing.
#

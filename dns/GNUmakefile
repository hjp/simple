include GNUmakevars
include GNUmakerules

all: gethostbyname fqdn
install: \
	$(BINDIR)/gethostbyname \
	$(BINDIR)/axfr \
	$(BINDIR)/fqdn \


clean:
	rm -f *.bak *.o core gethostbyname

distclean: clean
	rm -f *.d

cfg/%:
	$(MAKE) -C cfg all

gethostbyname: gethostbyname.o hstrerror.o

fqdn: fqdn.o hstrerror.o

hstrerror.o: cfg/have_hstrerror.h

axfr:

%: %.pl
	cp $< $@
	chmod +x $@

-include *.d

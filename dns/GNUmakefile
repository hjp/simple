include GNUmakevars

all: gethostbyname fqdn query
install: \
	$(BINDIR)/axfr \
	$(BINDIR)/fqdn \
	$(BINDIR)/gethostbyname \
	$(BINDIR)/minnet \
	$(BINDIR)/query \


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

GNUmakevars: GNUmakevars.sh
	sh ./$^ > $@
GNUmakerules: GNUmakerules.sh
	sh ./$^ > $@

include GNUmakerules

-include *.d

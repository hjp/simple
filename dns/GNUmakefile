include GNUmakevars

all: gethostbyaddr gethostbyname fqdn query check
install: \
	$(BINDIR)/axfr \
	$(BINDIR)/fqdn \
	$(BINDIR)/gethostbyaddr \
	$(BINDIR)/gethostbyname \
	$(BINDIR)/minnet \
	$(BINDIR)/query \
	$(BINDIR)/dns-inc-serial \


clean:
	rm -f *.bak *.o core gethostbyaddr gethostbyname fqdn check

distclean: clean
	rm -f *.d GNUmakevars GNUmakerules

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

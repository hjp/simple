include GNUmakevars
include GNUmakerules

all: gethostbyname
install: $(BINDIR)/gethostbyname

clean:
	rm -f *.bak *.o core gethostbyname

distclean: clean
	rm -f *.d

cfg/%:
	$(MAKE) -C cfg all

gethostbyname: gethostbyname.o hstrerror.o

hstrerror.o: cfg/have_hstrerror.h

-include *.d

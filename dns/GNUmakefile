include GNUmakevars
include GNUmakerules

all: gethostbyname
install: $(BINDIR)/gethostbyname

clean:
	rm -f *.bak *.o core gethostbyname

distclean: clean
	rm -f *.d

-include *.d

include GNUmakevars
include GNUmakerules

all: slowcat
install: $(BINDIR)/slowcat

clean:
	rm -f *.bak *.o core slowcat

distclean: clean
	rm -f *.d

-include *.d

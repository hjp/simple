include GNUmakevars
include GNUmakerules

all: ieeefloat
install: $(BINDIR)/ieeefloat

clean:
	rm -f *.bak *.o core ieeefloat

distclean: clean
	rm -f *.d

-include *.d

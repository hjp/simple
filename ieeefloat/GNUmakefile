include GNUmakevars

all: ieeefloat
install: $(BINDIR)/ieeefloat

clean:
	rm -f *.bak *.o core ieeefloat

distclean: clean
	rm -f *.d GNUmakerules GNUmakevars

ieeefloat: ieeefloat.o

GNUmakevars: GNUmakevars.sh
	sh ./$^ > $@
GNUmakerules: GNUmakerules.sh
	sh ./$^ > $@

include GNUmakerules
-include *.d

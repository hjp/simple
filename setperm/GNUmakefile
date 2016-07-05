include GNUmakevars

all: setperm

setperm:

clean:
	rm -f setperm

distclean: clean
	rm -f GNUmakerules GNUmakevars

install: $(BINDIR)/setperm

GNUmakevars: GNUmakevars.sh
	sh ./$^ > $@
GNUmakerules: GNUmakerules.pl
	perl ./$^ > $@

include GNUmakerules

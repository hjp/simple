include GNUmakevars

all: setperm

setperm:

clean:
	rm setperm
install: $(BINDIR)/setperm

GNUmakevars: GNUmakevars.sh
	sh ./$^ > $@
GNUmakerules: GNUmakerules.pl
	perl ./$^ > $@

include GNUmakerules

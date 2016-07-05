include GNUmakevars
include GNUmakerules

all: charhist

charhist: charhist.pl
	cp $^ $@

chartab:
clean:
	rm -f charhist core foo bar baz

distclean: clean
	rm -f GNUmakerules GNUmakevars

GNUmakevars: GNUmakevars.sh
	sh ./$^ > $@
GNUmakerules: GNUmakerules.pl
	perl ./$^ > $@

install: $(BINDIR)/charhist

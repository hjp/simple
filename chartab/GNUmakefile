-include GNUmakevars

all: chartab ctype-test

chartab: chartab.pl
	cp $^ $@

ctype-test:
clean:
	rm chartab
install: $(BINDIR)/chartab $(BINDIR)/ctype-test

GNUmakevars: GNUmakevars.sh
	sh ./$^ > $@
GNUmakerules: GNUmakerules.pl
	perl ./$^ > $@


-include GNUmakerules

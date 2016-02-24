include GNUmakevars
include GNUmakerules

all: charhist

charhist: charhist.pl
	cp $^ $@

chartab:
clean:
	rm -f charhist core foo bar baz

install: $(BINDIR)/charhist

include GNUmakevars

all: cvsdiffmin

clean:
	rm cvsdiffmin customize

install: $(BINDIR) $(BINDIR)/cvsdiffmin

%: %.pl customize
	sh ./customize < $< > $@
	chmod +x $@

%: %.sh customize
	sh ./customize < $< > $@
	chmod +x $@

customize: configure
	sh ./configure

$(BINDIR):
	mkdir -p $@

include GNUmakerules

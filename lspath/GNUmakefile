include GNUmakevars

all: lspath

clean:
	rm lspath customize

install: $(BINDIR) $(BINDIR)/lspath

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


include GNUmakevars

CONFDIR=../../configure

all: configure fact

clean:
	rm fact customize

install: $(BINDIR) $(BINDIR)/fact

%: %.pl customize
	sh ./customize < $< > $@
	chmod +x $@

%: %.sh customize
	sh ./customize < $< > $@
	chmod +x $@

customize: configure
	sh ./configure

configure: $(CONFDIR)/start $(CONFDIR)/perl $(CONFDIR)/finish
	cat $^ > $@

$(BINDIR):
	mkdir -p $@

include GNUmakerules


include GNUmakevars

CONFDIR=../../configure

all: configure oragetsrc

clean:
	rm oragetsrc customize

install: $(BINDIR) $(BINDIR)/oragetsrc

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


include GNUmakevars

BINDIR=/usr/local/bin

all: agestat

clean:
	rm agestat customize

install: $(BINDIR) $(BINDIR)/agestat

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

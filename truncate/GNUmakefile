include GNUmakevars

all: truncate

clean:
	rm truncate customize

install: $(BINDIR) $(BINDIR)/truncate $(MAN1DIR)/truncate.1

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


include GNUmakevars

all: mailsummary

clean:
	rm -f mailsummary *.bak

distclean: clean
	rm -f customize

install: $(BINDIR) $(BINDIR)/mailsummary

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

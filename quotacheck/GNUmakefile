include GNUmakevars
BINDIR=/usr/local/sbin

all: quotacheck quotastat

clean:
	rm -f quotacheck *.bak

distclean: clean
	rm -f customize

install: $(BINDIR) $(BINDIR)/quotacheck $(BINDIR)/quotastat

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

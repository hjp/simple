include GNUmakevars

TARGETS = quotacheck quotastat quotasanitycheck quotagraph
all: $(TARGETS)

clean:
	rm -f $(TARGETS) *.bak core foo bar baz *.ps

distclean: clean
	rm -f customize

install: $(SBINDIR) $(SBINDIR)/quotacheck $(SBINDIR)/quotastat \
	$(SBINDIR)/dfree \
	$(SBINDIR)/quotasanitycheck $(MAN8DIR)/quotasanitycheck.8 \
	/usr/local/dfstat/quotagraph 

%: %.pl customize
	sh ./customize < $< > $@
	chmod +x $@

%: %.sh customize
	sh ./customize < $< > $@
	chmod +x $@

customize: configure
	sh ./configure

$(SBINDIR):
	mkdir -p $@

/usr/local/dfstat/%: %
	$(INSTALL) -m 755 $^ $@

include GNUmakerules

include GNUmakevars

all: quotacheck quotastat quotasanitycheck

clean:
	rm -f quotacheck *.bak

distclean: clean
	rm -f customize

install: $(SBINDIR) $(SBINDIR)/quotacheck $(SBINDIR)/quotastat \
	$(SBINDIR)/quotasanitycheck $(MAN8DIR)/quotasanitycheck.8

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

include GNUmakerules

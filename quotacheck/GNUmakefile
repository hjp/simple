include GNUmakevars

CONFDIR=../../configure
CONFDIR_exists=$(shell [ -d $(CONFDIR) ] && echo ok)


TARGETS = quotacheck quotastat quotasanitycheck quotagraph
all: $(TARGETS)

clean:
	rm -f $(TARGETS) *.bak core foo bar baz *.ps

distclean: clean
	rm -f customize

install: $(SBINDIR) $(SBINDIR)/quotacheck $(SBINDIR)/quotastat \
	$(SBINDIR)/dfree \
	$(SBINDIR)/quotasanitycheck $(MAN8DIR)/quotasanitycheck.8 \
	/usr/local/dfstat/ \
	/usr/local/dfstat/quotagraph 

%: %.pl customize
	sh ./customize < $< > $@
	chmod +x $@

%: %.sh customize
	sh ./customize < $< > $@
	chmod +x $@

customize: configure
	sh ./configure

$(SBINDIR) /usr/local/dfstat/:
	mkdir -p $@

/usr/local/dfstat/%: %
	$(INSTALL) -m 755 $^ $@

ifeq ($(CONFDIR_exists),ok)

configure: $(CONFDIR)/start \
	$(CONFDIR)/perl \
	$(CONFDIR)/df \
	$(CONFDIR)/repquota \
	$(CONFDIR)/sendmail \
	$(CONFDIR)/scp \
	$(CONFDIR)/finish
	cat $^ > $@

endif

include GNUmakerules

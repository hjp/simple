include GNUmakevars

CONFDIR=../../configure
CONFDIR_exists=$(shell [ -d $(CONFDIR) ] && echo ok)

all: configure find_cvs_not_up_to_date

clean:
	rm -f find_cvs_not_up_to_date customize

distclean: clean


install: $(BINDIR) $(BINDIR)/find_cvs_not_up_to_date

%: %.pl customize
	sh ./customize < $< > $@
	chmod +x $@

%: %.sh customize
	sh ./customize < $< > $@
	chmod +x $@

customize: configure
	sh ./configure

ifeq ($(CONFDIR_exists),ok)

configure: $(CONFDIR)/start $(CONFDIR)/perl $(CONFDIR)/finish
	cat $^ > $@

endif

$(BINDIR):
	mkdir -p $@

include GNUmakerules


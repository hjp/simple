include GNUmakevars

TARGETS = cleandir cleandir.1
CONFDIR=../../configure
CONFDIR_exists=$(shell [ -d $(CONFDIR) ] && echo ok)

all: configure $(TARGETS)

clean:
	rm -f $(TARGETS) *.bak core foo bar baz *.ps

distclean: clean
	rm -f customize

install: $(BINDIR) $(BINDIR)/cleandir $(MAN1DIR)/cleandir.1

%.1: %.pl
	pod2man $< > $@

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

ifeq ($(CONFDIR_exists),ok)

configure: $(CONFDIR)/start $(CONFDIR)/perl $(CONFDIR)/finish
	cat $^ > $@

endif

GNUmakevars: GNUmakevars.sh
	sh ./$^ > $@
GNUmakerules: GNUmakerules.sh
	sh ./$^ > $@


include GNUmakerules

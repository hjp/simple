include GNUmakevars

CONFDIR=../../configure
CONFDIR_exists=$(shell [ -d $(CONFDIR) ] && echo ok)

all: configure grouplist groupmatch groupcount

clean:
	rm grouplist groupmatch

install: \
	$(BINDIR)/grouplist \
	$(BINDIR)/groupmatch \
	$(BINDIR)/groupcount \


%: %.pl customize
	sh ./customize < $< > $@
	chmod +x $@

customize: configure
	sh ./configure

ifeq ($(CONFDIR_exists),ok)

configure: $(CONFDIR)/start $(CONFDIR)/perl $(CONFDIR)/finish
	cat $^ > $@

endif

GNUmakevars: GNUmakevars.sh
	sh ./$^ > $@
GNUmakerules: GNUmakerules.pl
	perl ./$^ > $@

include GNUmakerules

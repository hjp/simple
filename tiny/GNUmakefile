include GNUmakevars

CONFDIR=../../configure
CONFDIR_exists=$(shell [ -d $(CONFDIR) ] && echo ok)

all: configure dus fnp fnpa fnpc isodate psg save

clean:
	rm fnp fnpa fnpc customize

install: \
	$(BINDIR)/dus \
	$(BINDIR)/fnp \
	$(BINDIR)/fnpa \
	$(BINDIR)/fnpc \
	$(BINDIR)/isodate \
	$(BINDIR)/psg \
	$(BINDIR)/save \
	$(BINDIR)/savedate \

fnp: fnp.sh
fnpa: fnpa.sh
fnpc: fnpc.sh

%: %.sh customize
	sh ./customize < $< > $@
	chmod +x $@

customize: configure
	sh ./configure

ifeq ($(CONFDIR_exists),ok)

configure: $(CONFDIR)/start $(CONFDIR)/find-printf $(CONFDIR)/finish
	cat $^ > $@

endif

include GNUmakerules

-include GNUmakevars

CONFDIR=../../configure
CONFDIR_exists=$(shell [ -d $(CONFDIR) ] && echo ok)

pre: GNUmakevars GNUmakerules 

GNUmakevars: GNUmakevars.sh
	sh ./$^ > $@
GNUmakerules: GNUmakerules.sh
	sh ./$^ > $@

all: configure dus fnp fnpa fnpc isodate psg save crypt

clean:
	rm -f fnp fnpa fnpc customize crypt

distclean: clean
	rm -f GNUmakevars GNUmakerules

install: \
	$(BINDIR)/crypt \
	$(BINDIR)/dus \
	$(BINDIR)/findsock \
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
crypt: crypt.pl

%: %.sh customize
	sh ./customize < $< > $@
	chmod +x $@

%: %.pl customize
	sh ./customize < $< > $@
	chmod +x $@

customize: configure
	sh ./configure

ifeq ($(CONFDIR_exists),ok)

configure: $(CONFDIR)/start \
	$(CONFDIR)/find-printf $(CONFDIR)/perl \
	$(CONFDIR)/finish
	cat $^ > $@

endif

-include GNUmakerules

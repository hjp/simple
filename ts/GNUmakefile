include GNUmakevars

CONFDIR=../../configure
CONFDIR_exists=$(shell [ -d $(CONFDIR) ] && echo ok)

all: configure ts

clean:
	rm ts

install: \
	$(BINDIR)/ts \

ts: ts.pl

%: %.pl customize
	sh ./customize < $< > $@
	chmod +x $@

customize: configure
	sh ./configure

ifeq ($(CONFDIR_exists),ok)

configure: $(CONFDIR)/start $(CONFDIR)/perl $(CONFDIR)/finish
	cat $^ > $@

endif

include GNUmakerules

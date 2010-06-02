include GNUmakevars

CONFDIR=../../configure
CONFDIR_exists=$(shell [ -d $(CONFDIR) ] && echo ok)

all: shuffle

shuffle: shuffle.o
	$(CC) $^ -lant -o $@

clean:
	rm -f *.o shuffle core foo bar

install: $(BINDIR)/shuffle

distclean: clean
	rm -f *.bak *.d

GNUmakevars: GNUmakevars.sh
	sh ./$^ > $@
GNUmakerules: GNUmakerules.sh
	sh ./$^ > $@

customize: configure
	sh ./configure

ifeq ($(CONFDIR_exists),ok)

configure: $(CONFDIR)/start $(CONFDIR)/perl $(CONFDIR)/finish
	cat $^ > $@

endif

include GNUmakerules

include GNUmakevars

CONFDIR=../../configure
CONFDIR_exists=$(shell [ -d $(CONFDIR) ] && echo ok)

all: configure ts

clean:
	rm -f ts ts.o

install: \
	$(BINDIR)/ts \

ts: %: %.o


#	$(LINK.o) $^ $(LOADLIBES) $(LDLIBS) -o $@

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

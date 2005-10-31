include GNUmakevars

TARGETS = apppath preppath delpath apppath.1 preppath.1 delpath.1
CONFDIR=../../configure
CONFDIR_exists=$(shell [ -d $(CONFDIR) ] && echo ok)

all: configure $(TARGETS)

clean:
	rm -f $(TARGETS) *.bak core foo bar baz *.ps

distclean: clean
	rm -f customize

install: $(BINDIR) \
    $(BINDIR)/apppath \
    $(BINDIR)/preppath \
    $(BINDIR)/delpath \
    $(MAN1DIR) \
    $(MAN1DIR)/apppath.1 \
    $(MAN1DIR)/preppath.1 \
    $(MAN1DIR)/delpath.1 \


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

$(BINDIR) $(MAN1DIR):
	mkdir -p $@

ifeq ($(CONFDIR_exists),ok)

configure: $(CONFDIR)/start $(CONFDIR)/perl $(CONFDIR)/finish
	cat $^ > $@

endif


include GNUmakerules

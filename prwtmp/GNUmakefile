include GNUmakevars
include GNUmakerules

prwtmp:

install: $(ROOT)/usr/local/bin/prwtmp $(ROOT)/usr/local/man/man8/prwtmp.8

clean:
	rm prwtmp

distclean: clean
	rm GNUmakerules GNUmakevars

$(ROOT)/usr/local/bin/%: %
	$(INSTALL) $< $@

$(ROOT)/usr/local/man/man8/%.8: %.man
	$(INSTALL) $< $@

GNUmakevars: GNUmakevars.sh
	sh ./$^ > $@
GNUmakerules: GNUmakerules.pl
	perl ./$^ > $@


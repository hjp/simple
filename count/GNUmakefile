include GNUmakerules
include GNUmakevars

acctfix:

install: $(ROOT)/usr/local/bin/count $(ROOT)/usr/local/man/man8/count.8

install_all:
	$(MAKE) install ROOT=/nfs/wsrdb
	$(MAKE) install ROOT=/nfs/wsrcom
	$(MAKE) install ROOT=/nfs/wifosv
	$(MAKE) install ROOT=/nfs/ihssv
	$(MAKE) install ROOT=/nfs/wsrtest

$(ROOT)/usr/local/bin/%: %
	$(INSTALL) $< $@

$(ROOT)/usr/local/man/man8/%.8: %.man
	$(INSTALL) $< $@

clean:
	rm count

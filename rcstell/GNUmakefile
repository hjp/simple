include GNUmakerules
include GNUmakevars

count:

install: $(ROOT)/usr/local/bin/rcstell \
	 $(ROOT)/usr/local/bin/rcsinfo \


install_all:
	$(MAKE) install ROOT=/nfs/wsrdb
	$(MAKE) install ROOT=/nfs/wsrcom
	$(MAKE) install ROOT=/nfs/wifosv
	$(MAKE) install ROOT=/nfs/ihssv
	$(MAKE) install ROOT=/nfs/wsrtest

$(ROOT)/usr/local/bin/rcsinfo: $(ROOT)/usr/local/bin/rcstell
	ln -s  $< $@

$(ROOT)/usr/local/man/man8/%.8: %.man
	$(INSTALL) $< $@

clean:
	rm count

include GNUmakevars
include GNUmakerules

rcstell:

install: /usr/local/bin/rcstell \
	 /usr/local/bin/rcsinfo \


install_all:
	$(MAKE) install ROOT=/nfs/wsrdb
	$(MAKE) install ROOT=/nfs/wsrcom
	$(MAKE) install ROOT=/nfs/wifosv
	$(MAKE) install ROOT=/nfs/ihssv
	$(MAKE) install ROOT=/nfs/wsrtest

/usr/local/bin/rcsinfo: /usr/local/bin/rcstell
	ln -s  $< $@

/usr/local/man/man8/%.8: %.man
	$(INSTALL) $< $@

clean:
	rm count

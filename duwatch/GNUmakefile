install: $(ROOT)/usr/local/bin/duwatch
install_all:
	make install ROOT=/nfs/wsrdb
	make install ROOT=/nfs/wifosv
	make install ROOT=/nfs/ihssv
	make install ROOT=/nfs/wsrcom

$(ROOT)/usr/local/bin/%: %
	install $< $@

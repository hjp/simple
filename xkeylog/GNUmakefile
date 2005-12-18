all: xkeylog
xkeylog: xkeylog.c
	gcc -O xkeylog.c -L/usr/X11R6/lib -lX11 -o xkeylog

install: /usr/local/bin/xkeylog

/usr/local/bin/xkeylog: xkeylog
	cp $^ $@

BINDIR=/usr/local/bin
CC = gcc
CFLAGS = -Wall -ansi -pedantic -O2 -g
fix2var: fix2var.o
	$(CC) $^ -lant -o $@

install: $(BINDIR)/fix2var
$(BINDIR)/%: %
	install $< $@

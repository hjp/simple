CC	= gcc
CFLAGS	= -O2

BINDIR	= /usr/local/bin

fortune: fortune.c
	$(CC) $(CFLAGS)	-o fortune fortune.c -lant
	
clean:
	rm fortune core

install: $(BINDIR)/fortune

$(BINDIR)/fortune: fortune
	cp fortune $(BINDIR)/fortune


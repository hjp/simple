include GNUmakevars
include GNUmakerules

all: scat $(patsubst %.msg, %.cat, $(wildcard *.msg))

scat: scat.o
scat.o: scat.c scat.h
scat.h: scat.en.msg
	gencat -H scat.h scat.en.cat scat.en.msg

%.cat: %.msg
	gencat $@ $^

clean:
	rm -f *.cat *.o scat core scat.h

install: $(BINDIR)/scat

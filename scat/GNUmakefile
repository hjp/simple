include GNUmakevars

all: scat $(patsubst %.msg, %.cat, $(wildcard *.msg))

scat: scat.o
scat.o: scat.c scat.h
scat.h: scat.en.msg
	gencat -H scat.h -o scat.en.cat scat.en.msg

%.cat: %.msg
	gencat $@ $^

clean:
	rm -f *.cat *.o scat core scat.h

distclean: clean
	rm -f GNUmakerules GNUmakevars

install: $(BINDIR)/scat

GNUmakevars: GNUmakevars.sh
	sh ./$^ > $@
GNUmakerules: GNUmakerules.sh
	sh ./$^ > $@

include GNUmakerules

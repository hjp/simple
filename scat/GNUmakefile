include GNUmakevars
include GNUmakerules

all: scat

scat: scat.o
scat.o: scat.c scat.h
scat.h: scat.en.msg
	gencat -H scat.h scat.en.cat scat.en.msg

%.cat: %.msg
	gencat $@ $^

clean:
	rm -f *.cat *.o scat core
install: $(BINDIR)/time_t

include GNUmakevars

all: time_t

time_t:
clean:
	rm time_t

distclean: clean
	rm GNUmakevars GNUmakerules
install: $(BINDIR)/time_t

GNUmakevars: GNUmakevars.sh
	sh ./$^ > $@
GNUmakerules: GNUmakerules.sh
	sh ./$^ > $@

include GNUmakerules

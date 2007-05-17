include GNUmakevars

all: time_t

time_t:
clean:
	rm time_t
install: $(BINDIR)/time_t

GNUmakevars: GNUmakevars.sh
	sh ./$^ > $@
GNUmakerules: GNUmakerules.sh
	sh ./$^ > $@

include GNUmakerules

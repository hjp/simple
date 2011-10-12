include GNUmakevars
setperm:
clean:
	rm setperm
install: $(BINDIR)/setperm

GNUmakevars: GNUmakevars.sh
	sh ./$^ > $@
GNUmakerules: GNUmakerules.sh
	sh ./$^ > $@

include GNUmakerules

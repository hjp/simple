include GNUmakevars
include GNUmakerules

shuffle: shuffle.o
	$(CC) $^ -lant -o $@

clean:
	rm -f *.o shuffle core foo bar

install: $(BINDIR)/shuffle

distclean: clean
	rm -f *.bak *.d

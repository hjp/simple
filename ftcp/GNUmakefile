include GNUmakevars
include GNUmakerules

ftcp: ftcp.o
	$(CC) $^ -lant -o $@

clean:
	rm -f *.o ftcp core foo bar

install: $(BINDIR)/ftcp

distclean: clean
	rm -f *.bak *.d

include GNUmakevars
include GNUmakerules

base64: base64.o
	$(CC) $^ -lant -o $@

clean:
	rm -f *.o base64 core foo bar

install: $(BINDIR)/base64

distclean: clean
	rm -f *.bak *.d

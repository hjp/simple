include GNUmakevars
include GNUmakerules

fotoindex:

install: /usr/local/bin/fotoindex


/usr/local/man/man8/%.8: %.man
	$(INSTALL) $< $@

clean:
	rm -f *.gif *.jpg core foo bar baz

all: have_hstrerror.h

%.h: %.sh
	CC='$(CC)' CFLAGS='$(CFLAGS)' LDFLAGS='$(LDFLAGS)' sh $^ > $@

clean:
	rm *.h

include GNUmakevars
include GNUmakerules

all: waste

errno:
clean:
	rm waste
install: $(BINDIR)/waste

%: %.pl patchperl
	sh ./patchperl $< $@

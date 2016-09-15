#!/bin/sh
echo "\$(BINDIR)/%: %"
echo "	cp \$^ \$@"
echo "\$(MAN1DIR)/%: %"
echo "	cp \$^ \$@"

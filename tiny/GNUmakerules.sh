#!/bin/sh
echo "\$(BINDIR)/%: %"
echo "	cp \$^ \$@"

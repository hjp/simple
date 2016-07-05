#!/bin/sh
echo "\$(BINDIR)/%: %"
echo "\tcp \$^ \$@"

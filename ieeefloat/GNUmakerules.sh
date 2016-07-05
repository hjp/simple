#!/bin/sh
echo "\$(BINDIR)/%: %"
echo "\tcp \$^ \$@"
echo "\$(MAN1DIR)/%: %"
echo "\tcp \$^ \$@"

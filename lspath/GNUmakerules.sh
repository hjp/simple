#!/bin/sh
echo "\$(BINDIR)/%: %"
echo -e "\tcp \$^ \$@"

#!/bin/sh
echo "\$(BINDIR)/%: %"
echo -e "\tcp \$^ \$@"
echo "\$(MAN1DIR)/%: %"
echo -e "\tcp \$^ \$@"

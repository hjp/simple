#!/usr/bin/perl
use warnings;
use strict;

print "\$(BINDIR)/%: %\n";
print "\tinstall -m 755 \$^ \$@\n";
print "\$(MAN1DIR)/%: %\n";
print "\tinstall -m 644 \$^ \$@\n";

#!/usr/bin/perl
use warnings;
use strict;

print "\$(BINDIR)/%: %\n";
print "\tcp \$^ \$@\n";
print "\$(MAN1DIR)/%: %\n";
print "\tcp \$^ \$@\n";

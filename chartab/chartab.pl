#!/usr/bin/perl 
use warnings;
use strict;
use charnames ();

use Getopt::Long;
use Pod::Usage;

my $all;

GetOptions(
    'all' => \$all
) or pod2usage(2);

binmode STDOUT, ":encoding(UTF-8)";
for my $c (0 .. 0xFFFF) {
    my $cc = pack('U', $c);
    if (charnames::viacode($c) || $all) {
	printf("%04x %5d %06o %s %s\n",
	       $c,
	       $c,
	       $c,
	       (($cc =~ /[[:print:]]/) ? $cc : '.'),
	       charnames::viacode($c) || ''
	);
    }
}
print "\n";

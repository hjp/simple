#!/usr/bin/perl
use warnings;
use strict;
use Getopt::Long;
use Pod::Usage;
use autodie;

my $encoding;

GetOptions('encoding=s', \$encoding) or pod2usage();

my %hist;
if (@ARGV) {
    readfile($_) for @ARGV;
} else {
    readfile();
}

my $total = 0;
$total += $_ for values %hist;

binmode STDOUT, ":encoding(UTF-8)";
for (sort keys %hist) {
    my $cp = ord;
    printf("%x %d %o %s\t%8d %f\n",
           $cp, $cp, $cp, /\p{Graph}/ ? $_ : ".", $hist{$_}, $hist{$_} / $total);
}

sub readfile {
    my ($filename) = @_;
    my $fh;
    if (defined $filename) {
        open $fh, "<", $filename;
    } else {
        $fh = \*STDIN;

    }
    binmode $fh, ":encoding($encoding)";
    while (<$fh>) {
        for my $c (split(//)) {
            $hist{$c}++;
        }
    }
}

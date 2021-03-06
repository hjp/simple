#!/usr/bin/perl
use warnings;
use strict;
use autodie;

use Getopt::Long;
use I18N::Langinfo qw(langinfo CODESET);
use Pod::Usage;

my $encoding = langinfo(CODESET);

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
    printf("%x\t%d\t%o\t%s\t%7d\t%f\n",
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

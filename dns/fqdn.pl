#!/usr/bin/perl
use v5.26;

sub fqdn {
    my ($h) = @_;

    if ($h =~ /\./) {
        return $h;
    }
    open(my $fh, '-|', '/usr/bin/host', $h);
    while (<$fh>) {
        if (/^(\S+\.\S+) has address/) {
            return $1;
        }
    }
    say STDERR "$0: cannot determine FQDN of $h";
    return "$h.invalid";
}

if (!@ARGV) {
    $ARGV[0] = `/bin/hostname -f`;
    chomp($ARGV[0]);
}

for my $h (@ARGV) {
    say fqdn($h);
}

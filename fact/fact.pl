#!@@@perl@@@ -w
use strict;

sub usage {
    print STDERR "Usage: $0 number\n";
    exit(1);
}

sub fact {
    my ($n) = @_;

    my $d = 2;

    my @f = ();

    while ($d <= $n) {
	if ($n % $d == 0) {
	    push (@f, $d);
	    $n /= $d;
	} else {
	    $d++;
	}
    }
    return @f;
}

if (@ARGV != 1) { usage(); }
my @f = fact($ARGV[0]);
print "@f\n";

#vim:sw=4

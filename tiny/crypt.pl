#!@@@perl@@@ -w
use strict;

unless (@ARGV == 2) {
    print STDERR "Usage: $0 password salt\n";
    exit(2);
}
my $encpwd = crypt($ARGV[0], $ARGV[1]);
print "$encpwd\n";
exit($ARGV[1] eq $encpwd ? 0 : 1);

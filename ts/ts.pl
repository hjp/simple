#!@@@perl@@@ -wT
use strict;
use POSIX;
while (<>) {
    chomp;
    my $now = strftime('%Y-%m-%dT%H:%M:%S', localtime);
    print "$now $_\n";
}

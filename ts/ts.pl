#!@@@perl@@@ -wT
use strict;
use POSIX;
use Time::HiRes qw(gettimeofday);
my $use_microseconds;
if ($ARGV[0] eq '-u') {
    $use_microseconds = 1;
    shift;
}
while (<>) {
    chomp;
    my ($seconds, $microseconds) = gettimeofday;
    my $now = strftime('%Y-%m-%dT%H:%M:%S', localtime($seconds));
    if ($use_microseconds) {
	printf "%s.%06d %s\n", $now, $microseconds, $_;
    } else {
	print "$now $_\n";
    }
}

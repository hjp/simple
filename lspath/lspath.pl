#!@@@perl@@@ -w
use strict;


my @pp;
for my $p (@ARGV) {

    my @p = split (/\//, $p);
    for (my $i = 0; $i < scalar(@p); $i++) {
	my $pp = join("/", @p[0..$i]);
	$pp = "/" if $pp eq "";

	push (@pp, $pp);
    }
}
system("/bin/ls", "-fldi", @pp);

#!@@@perl@@@ -w
use strict;


for my $p (@ARGV) {

    my @p = split (/\//, $p);
    for (my $i = 0; $i < scalar(@p); $i++) {
	my $pp = join("/", @p[0..$i]);
	$pp = "/" if $pp eq "";

	system("/bin/ls", "-ldi", $pp);
    }
}

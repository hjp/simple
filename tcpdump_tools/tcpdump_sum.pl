#!/usr/bin/perl

# print summary of tcpdump output

sub dumpstats {
    print "-" x 60, "\n";
    print "$time_last\n";
    for $i (sort { $sum{$a} <=> $sum{$b} } keys (%sum)) {
	printf("\t%6d %s\n", $sum{$i}, $i);
    }
}

while (<>) {
    if (m/^(\d\d:\d\d):\d\d\.\d{6} ([-\w\.]+) \> ([-\w\.]+): (.*)/) {
	$time = $1;
	$from = $2;
	$to = $3;
	$rest = $4;
	if ($time ne $time_last) {
	    dumpstats();
	    undef %sum;
	    $time_last = $time;
	}
	if ($rest =~ m/^. (\d+):(\d+)\((\d+)\)/) {
	    # tcp
	    $sum{$from . " > " . $to} += $3;
	} elsif ($rest =~ m/^. ack (\d+) win (\d+) \(DF\)/) {
	    # tcp ack 
	    $sum{$from . " > " . $to} += 0;
	} else {
	    print stderr "unparseable2: $_";
	}
	    
	    
    } else {
	print stderr "unparseable1: $_";
    }
}
dumpstats();

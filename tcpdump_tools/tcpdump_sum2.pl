#!/usr/bin/perl

# print summary of tcpdump output

sub dumpstats {
    print "-" x 60, "\n";
    print "$time_last\n";
    for $i (sort { $sum{$a} <=> $sum{$b} } keys (%sum)) {
	printf("\t%6d %s\n", $sum{$i}, $i);
    }
}

$maxsecs = 0;
$minsecs = 86400;

while (<>) {
    if (m/^(\d\d:\d\d:\d\d)\.\d{6} ([-\w\.]+) \> ([-\w\.]+): (.*)/) {
	$time = $1;
	$from = $2;
	$to = $3;
	$rest = $4;
	@t = split(/:/, $time);
	$secs = $t[0] * 3600 + $t[1] * 60 + $t[2];
	if ($secs < $minsecs) {$minsecs = $secs}
	if ($secs > $maxsecs) {$maxsecs = $secs}

	if ($rest =~ m/^. (\d+):(\d+)\((\d+)\)/) {
	    # tcp
	    $con = "$from > $to";
	    $tsum{$con} += $3;
	    if (!$sum{$con}) {
		$sum{$con} = [];
	    }
	    $sum{$con}->[$secs] += $3;
		

	} elsif ($rest =~ m/^. ack (\d+) win (\d+) \(DF\)/) {
	    # tcp ack 
	} else {
	    #print stderr "unparseable2: $_";
	}
	    
	    
    } else {
	#print stderr "unparseable1: $_";
    }
}

for $c ((sort {$tsum{$b} <=> $tsum{$a}} keys %tsum)[0..9]) {
    print "# ", $c, " ", $tsum{$c}, "\n";
    for ($s = $minsecs; $s <= $maxsecs; $s++) {
	print $c, "\t", $s, "\t", $sum{$c}->[$s] + 0, "\n";
    }
}

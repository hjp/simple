#!@@@perl@@@

%mon2num = (
    Jan =>  1,
    Feb =>  2,
    Mar =>  3,
    Apr =>  4,
    May =>  5,
    Jun =>  6,
    Jul =>  7,
    Aug =>  8,
    Sep =>  9,
    Oct => 10,
    Nov => 11,
    Dec => 12
);
$header = 0;

foreach $f (@ARGV) {
  if (!open(F, $f)) {next};
  $header = 1;
  $from = ""; 
  $date = ""; 
  $subject = ""; 
  $to = ""; 

  while (<F>) {
    if (/^From ([^ ]*) /) {
        $from = $1;
	$header = 1;
	if (/
	     (?:(?:Mon|Tue|Wed|Thu|Fri|Sat|Sun)\s)?
	     (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\s
	     ([0-9]?[0-9])\s
	     ([0-9]?[0-9]:[0-9][0-9]:[0-9][0-9])\s
	     (19[0-9][0-9])
	     /x) {
	    $date = sprintf("%04d-%02d-%02d %8s", $4, $mon2num{$1}, $2, $3);
	} else {
	    $date = "XXXX-XX-XX XX:XX:XX";
	}
    } elsif ($header && /^Date:/) {
	# Thu, 22 May 1997 16:49:23 +0200
	if (/^Date:\s+
	     (?:(?:Mon|Tue|Wed|Thu|Fri|Sat|Sun),\s+)?
	     ([0-9]?[0-9])\s
	     (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\s
	     (19[0-9][0-9])\s+
	     ([0-9]?[0-9]:[0-9][0-9]:[0-9][0-9])/x) {
	    $date = sprintf("%04d-%02d-%02d %8s", $3, $mon2num{$2}, $1, $4);
	} elsif (/^Date:\s+
	     (?:(?:Mon|Tue|Wed|Thu|Fri|Sat|Sun),\s+)?
	     ([0-9]?[0-9])\s
	     (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\s
	     ([7-9][0-9])\s+
	     ([0-9]?[0-9]:[0-9][0-9]:[0-9][0-9])/x) {
	    $date = sprintf("%04d-%02d-%02d %8s", 1900 + $3, $mon2num{$2}, $1, $4);
	} else {
	   print "bad date: $_\n";
	}
    } elsif ($header && /^To:/) {
	if (/^To:\s+(.*)/) {
	    $to = $1;
	} else {
	   print "bad to: $_\n";
	}
    } elsif ($header && /^Subject:/) {
	if (/^Subject:\s+(.*)/) {
	    $subject = $1;
	} else {
	   print "bad subject: $_\n";
	}
    } elsif ($header && /^From:/) {
	if (/^From:\s+(.*)/) {
	    $from = $1;
	} else {
	   print "bad from: $_\n";
	}
    } elsif ($header && /^$/) {
	print "$date\t$f\t$from\t$to\t$subject\n";
	$header=0;
    }
  }
  close(F);
}

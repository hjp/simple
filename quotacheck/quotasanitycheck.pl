#!@@@perl@@@
#
# $Id: quotasanitycheck.pl,v 1.1 1998-09-17 08:32:57 hjp Exp $
# $Log: quotasanitycheck.pl,v $
# Revision 1.1  1998-09-17 08:32:57  hjp
# CVS cleanups:
# 	Added quotasanitycheck.pl and removed quotasanitycheck.
# 	Added quotasanitycheck
#
#
# check quotas for sanity:
#     *	for each user, the difference between current usage and hard
#	limit must be less than the available space (preferably much
#	less).
#     * all quotas must be above some limit
#     * soft quotas  must be less than hard quotas.

use Getopt::Std;

$opts{'b'} = 1;
$opts{'f'} = 1;
$opts{'F'} = 1;

getopts('b:f:F:', \%opts);

print "b=", $opts{'b'}, "f=", $opts{'f'}, "F=", $opts{'F'}, "\n"; 

$blmin = $opts{'b'};
$flmin = $opts{'f'};

$hostname=`hostname`;
chomp($hostname);
open (DF, "@@@df@@@ |") or die "cannot call @@@df@@@: $!";

$fs = $/;
undef ($/);
$df = <DF>;
close(DF);
$/ = $fs;

$df =~ s/\n[ \t]+/ /mg;
@df = split(/\n/, $df); 
for $ln (@df) {
    ($fs, $total, $used, $free, $pct, $mount) = split(/\s+/, $ln);
    if ($fs =~ m|^/dev/|) {
	open REPQUOTA, "@@@repquota@@@ $mount 2>/dev/null |" or die "cannot call @@@repquota@@@: $!";
	while (<REPQUOTA>) {
	    if  (/(\w+) \s+ [-+][-+] \s*
	         (\d+)\s+(\d+)\s+(\d+)\s+(NOT\sSTARTED|EXPIRED|\d+\.\d+\ (?:days|hours)|)\s+
	         (\d+)\s+(\d+)\s+(\d+)\s+(NOT\sSTARTED|EXPIRED|\d+\.\d+\ (?:days|hours)|)
		 /x) {
		$user = $1;
		$bluse = $2;
		$blsoft = $3;
		$blhard = $4;
		$fluse = $6;
		$flsoft = $7;
		$flhard = $8;
		print "$mount $user";
		print "   block limit";
		print " soft $blsoft hard $blhard";
		if ($blsoft >= $blmin) {
		    print " min_ok";
		} else {
		    print " min_FAIL";
		}
		if ($blsoft < $blhard) {
		    print " softhard_ok";
		} else  {
		    print " softhard_FAIL";
		}
		if ($blhard - $bluse < $free * $opts{'F'}) {
		    print " hardfree_ok";
		} else {
		    print " hardfree_FAIL";
		}

		print "   file limit";
		print " soft $flsoft hard $flhard";
		if ($flsoft >= $flmin) {
		    print " min_ok";
		} else {
		    print " min_FAIL";
		}
		if ($flsoft < $flhard) {
		    print " softhard_ok";
		} else {
		    print " softhard_FAIL";
		}
		if ($flhard - $fluse < $free) {
		    print " hardfree_ok";
		} else {
		    print " hardfree_FAIL";
		}
		print "\n";

	    } else {
		if ($. > 2) {	# ignore header lines
		    print "$mount: $.: unparseable: $_";
		}
	    }
		
	}
	close (REPQUOTA);
    }
}

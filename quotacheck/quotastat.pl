#!@@@perl@@@

$hostname=`hostname`;
chomp($hostname);
$date=`date '+%Y-%m-%dT%H:%M:%S'`;
chomp($date);
open (DF, "@@@df@@@ |") or die "cannot call @@@df@@@: $!";

$fs = $/;
undef ($/);
$df = <DF>;
close(DF);
$/ = $fs;

$df =~ s/\n[ \t]+/ /mg;
@df = split(/\n/, $df); 

open (STAT, ">>/usr/local/dfstat/quota.stat") or die "cannot append to quota.stat";
for $ln (@df) {
    ($fs, $total, $used, $free, $pct, $mount) = split(/\s+/, $ln);
    if ($fs =~ m|^/dev/| and -f "$mount/quotas") {
	open REPQUOTA, "@@@repquota@@@ $mount |" or die "cannot call @@@repquota@@@: $!";
	while (<REPQUOTA>) {
	    $msg = "";
	    if (!/\d+/) {
		#print "header: $_";
	    } elsif  (/(\w+) \s+ [-+][-+] \s*
	         (\d+)\s+(\d+)\s+(\d+)\s+(|NOT\sSTARTED|EXPIRED|\d+\.\d+\ (?:days|hours))\s+
	         (\d+)\s+(\d+)\s+(\d+)\s+(|NOT\sSTARTED|EXPIRED|\d+\.\d+\ (?:days|hours))
		 /x) {
		print STAT "$date\t$mount\t$1\t$2\t$3\t$4\t$6\t$7\t$8\n";
	    } else {
		print "unparseable: $_";
	    }
	}
    }
}

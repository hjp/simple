#!@@@perl@@@

$hostname=`hostname`;
chomp($hostname);
($sec, $min, $hour, $day, $mon, $year) = localtime(time);
$year += 1900;
$mon  += 1;

$yearmon=sprintf("%4d-%02d", 
	      $year, $mon);
$datetime=sprintf("%4d-%02d-%02dT%02d:%02d:%02d", 
	      $year, $mon, $day, $hour, $min, $sec);
chomp($date);
open (DF, "@@@df@@@ |") or die "cannot call @@@df@@@: $!";

$fs = $/;
undef ($/);
$df = <DF>;
close(DF);
$/ = $fs;

$df =~ s/\n[ \t]+/ /mg;
@df = split(/\n/, $df); 

open (STAT, ">>/usr/local/dfstat/quota.stat.$yearmon") or die "cannot append to quota.stat.$yearmon";
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
		print STAT "$datetime\t$mount\t$1\t$2\t$3\t$4\t$6\t$7\t$8\n";
	    } else {
		print "unparseable: $_";
	    }
	}
    }
}
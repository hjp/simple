#!@@@perl@@@

sub warnmsg {
    my ($mount, $usage, $soft, $hard, $grace, $unit) = @_;

    my $msg = "Sie haben auf $mount (Host $hostname) Ihr Limit von $soft $unit " .
	    "um " . ($usage - $soft) . " $unit überschritten.\n";

    if ($grace eq "EXPIRED" or $usage >= $hard-2) {
	$msg .= "Sie können dort KEINE Files mehr anlegen.\n" .
		"Bitte löschen Sie eine entsprechende Anzahl Files\n" .
		"oder wenden Sie sich an einen Systemadministrator.\n";
    } else {
	$grace =~ s/days/Tage/g;
	$grace =~ s/hours/Stunden/g;
	$msg .= "Sie können dieses Limit noch $grace um maximal " .
		($hard - $soft) . " $unit überschreiten.\n" .
		"Sollte das nicht reichen, wenden Sie sich an einen Systemadministrator.\n";
    }
    return $msg;
}


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
	print $mount, "\n";
	open REPQUOTA, "@@@repquota@@@ $mount |" or die "cannot call @@@repquota@@@: $!";
	while (<REPQUOTA>) {
	    $msg = "";
	    if (/(\w+) \s+ -- \s*
	         (\d+)\s+(\d+)\s+(\d+)\s+
	         (\d+)\s+(\d+)\s+(\d+)
		 /x) {
		#print "ok: $1\n";
	    } elsif  (/(\w+) \s+ \+- \s*
	         (\d+)\s+(\d+)\s+(\d+)\s+(EXPIRED|\d+\.\d+\ (?:days|hours))\s+
	         (\d+)\s+(\d+)\s+(\d+)
		 /x) {
		print "block limit: $1: $2 > ($3 $4) $5\n";
		$user = $1;
		$msg = warnmsg($mount, $2, $3, $4, $5, "kB");

	    } elsif  (/(\w+) \s+ -\+ \s*
	         (\d+)\s+(\d+)\s+(\d+)\s+
	         (\d+)\s+(\d+)\s+(\d+)\s+(EXPIRED|\d+\.\d+\ (?:days|hours))
		 /x) {
		print "file limit: $1: $5 > ($6 $7) $8\n";
		$user = $1;
		$msg = warnmsg($mount, $5, $6, $7, $8, "Files");
	    } elsif  (/(\w+) \s+ \+\+ \s*
	         (\d+)\s+(\d+)\s+(\d+)\s+(EXPIRED|\d+\.\d+\ (?:days|hours))\s+
	         (\d+)\s+(\d+)\s+(\d+)\s+(EXPIRED|\d+\.\d+\ (?:days|hours))
		 /x) {
		print "block limit: $1: $2 > ($3 $4) $5\n";
		$user = $1;
		$msg = warnmsg($mount, $2, $3, $4, $5, "kB");
		print "file limit: $1: $6 > ($7 $8) $9\n";
		$msg .= "\n\n" . warnmsg($mount, $6, $7, $8, $9, "Files");
	    } else {
		print "unparseable: $_";
	    }
	    if ($msg) {
		open (SENDMAIL, "|@@@sendmail@@@ -t -i");
		print SENDMAIL "To: <$user\@wsr.ac.at>\r\n";
		print SENDMAIL "Cc: <system\@wsr.ac.at>\r\n";
		print SENDMAIL "Reply-To: <system\@wsr.ac.at>\r\n";
		print SENDMAIL "Subject: Disk Quotas überschritten\r\n";
		print SENDMAIL "\r\n";
		print SENDMAIL "$msg\r\n";
	    }
		
	}
    }
}

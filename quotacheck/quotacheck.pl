#!@@@perl@@@

use Getopt::Std;

sub warnmsg {
    my ($mount, $usage, $soft, $hard, $grace, $unit) = @_;
    %dosdrv = (
	'/wifosv/dosprogs' => 'H:',
	'/wsrdb/users'     => 'J:',
	'/wifosv/users'    => 'K:',
	'/usr/local/www'   => 'W:',
    );

    if ($dosdrv{$mount}) {
	$wo = 'Netzplatte ' . $dosdrv{$mount};
    } else {
	$wo = "$mount (Host $hostname)";
    }

    my $msg = "Sie haben auf $wo Ihr in Disk Quotas gesetztes Limit\n" .
	    "überschritten. ";

    if ($grace eq "EXPIRED" or $usage >= $hard-2) {
	$msg .= "Sie können dort KEINE Files mehr anlegen.\n" ;
    } else {
	$grace =~ s/days/Tage/g;
	$grace =~ s/hours/Stunden/g;
	$msg .= "Sie können noch " .
		($hard - $usage) . " $unit anlegen.\n" ;
    }
    $msg .= "\nBei dringendem Bedarf können Sie sofort zusätzlichen Platz schaffen,\n" .
    	    "indem Sie auf $wo Files löschen, komprimieren oder auf eine\n" .
	    "andere Netzplatte verschieben.\n" .
	    "\n" .
	    "Lassen Sie sich bei Gelegenheit auch von einem der zuständigen\n" .
	    "Systemadministratoren unterstützen:\n" .
	    "Peter Holzer, hjp\@wsr.ac.at, Kl. 786\n" .
	    "Michael Demelbauer, michael\@wsr.ac.at, Kl. 787\n";
    return $msg;
}

getopts('ad', \%opts);

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
	    $msg = "";
	    if (/(\w+) \s+ -- \s*
	         (\d+)\s+(\d+)\s+(\d+)\s+
	         (\d+)\s+(\d+)\s+(\d+)
		 /x) {
		#print "ok: $1\n";
	    } elsif  (/(\w+) \s+ \+- \s*
	         (\d+)\s+(\d+)\s+(\d+)\s+(NOT\sSTARTED|EXPIRED|\d+\.\d+\ (?:days|hours))\s+
	         (\d+)\s+(\d+)\s+(\d+)
		 /x) {
		print "block limit: $1: $2 > ($3 $4) $5\n";
		$user = $1;
		$msg = warnmsg($mount, $2/1024, $3/1024, $4/1024, $5/1024, "MB");

	    } elsif  (/(\w+) \s+ -\+ \s*
	         (\d+)\s+(\d+)\s+(\d+)\s+
	         (\d+)\s+(\d+)\s+(\d+)\s+(NOT\sSTARTED|EXPIRED|\d+\.\d+\ (?:days|hours))
		 /x) {
		print "file limit: $1: $5 > ($6 $7) $8\n";
		$user = $1;
		$msg = warnmsg($mount, $5, $6, $7, $8, "Files");
	    } elsif  (/(\w+) \s+ \+\+ \s*
	         (\d+)\s+(\d+)\s+(\d+)\s+(NOT\sSTARTED|EXPIRED|\d+\.\d+\ (?:days|hours))\s+
	         (\d+)\s+(\d+)\s+(\d+)\s+(NOT\sSTARTED|EXPIRED|\d+\.\d+\ (?:days|hours))
		 /x) {
		print "block limit: $1: $2 > ($3 $4) $5\n";
		$user = $1;
		$msg = warnmsg($mount, $2/1024, $3/1024, $4/1024, $5/1024, "MB");
		print "file limit: $1: $6 > ($7 $8) $9\n";
		$msg .= "\n\n" . warnmsg($mount, $6, $7, $8, $9, "Files");
	    } else {
		if ($. > 2) {	# ignore header lines
		    print "$mount: $.: unparseable: $_";
		}
	    }
	    if ($msg) {
		if ($opts{'d'}) {
		    open (SENDMAIL, ">&1");
		} else {
		    open (SENDMAIL, "|@@@sendmail@@@ -t -i");
		}
		if ($opts{'a'}) {
		    print SENDMAIL "To: <system\@wsr.ac.at>\r\n";
		    print SENDMAIL "Subject: User $user: Disk Quotas überschritten\r\n";
		} else {
		    print SENDMAIL "To: <$user\@wsr.ac.at>\r\n";
		    print SENDMAIL "Cc: <system\@wsr.ac.at>\r\n";
		    print SENDMAIL "Subject: Disk Quotas überschritten\r\n";
		}
		print SENDMAIL "Reply-To: <system\@wsr.ac.at>\r\n";
		print SENDMAIL "\r\n";
		print SENDMAIL "$msg\r\n";
	    }
		
	}
	close (REPQUOTA);
    }
}

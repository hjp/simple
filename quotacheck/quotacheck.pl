#!@@@perl@@@ -w 

use strict;

use Getopt::Std;
my $time=time;
my @time=localtime($time);
my $hostname;

sub warnmsg {
    my ($mount, $usage, $soft, $hard, $grace, $unit, $user) = @_;
    my %dosdrv = (
	'/wsrdb/users'     => 'J:',
	'/usr/local/www'   => 'W:',
    );

    my $wo;
    if ($dosdrv{$mount}) {
	$wo = 'Netzplatte ' . $dosdrv{$mount};
    } else {
	$wo = "$mount (Host $hostname)";
    }


    my $msg = "Sie haben auf $wo Ihr in Disk Quotas gesetztes Limit\n" .
	    "überschritten. \n";
	    
    if ($grace eq "EXPIRED" or $usage >= $hard-2) {
	$msg .= "Sie können dort KEINE Files mehr anlegen.\n" ;
    } else {
	$grace =~ s/days/Tage/g;
	$grace =~ s/hours/Stunden/g;
	$msg .= "Sie können noch " .
		(int (($hard - $usage) * 10 + 0.5) / 10) . " $unit anlegen.\n" ;
    }
    my $mount_t = $mount;
    $mount_t =~ s|/|_|g;

    $msg .= "\nBei dringendem Bedarf können Sie sofort zusätzlichen Platz schaffen,\n" .
    	    "indem Sie auf $wo Files löschen, komprimieren oder auf eine\n" .
	    "andere Netzplatte verschieben.\n" .
	    "\n" .
	    "Sie können sich Ihre Verbrauchsgraphen unter\n" .
	    "http://sww.wsr.ac.at/intranet/quotas/$user$mount_t.gif ansehen. \n" .
	    "Der Graph zeigten den verbrauchten Platz ("used") sowie die beiden\n" .
	    "Quotas ("soft" und "hard")\n" .
	    "Die Softquota können Sie kurzfristig (bis zu einer Woche) überschreiten\n" .
	    "die Hardquota nicht.\n" .
	    "\n" .
	    "Lassen Sie sich bei Gelegenheit auch von einem der zuständigen\n" .
	    "Systemadministratoren unterstützen:\n" .
	    "Peter Holzer, hjp\@wsr.ac.at, Kl. 786\n" .
	    "Gina Lanik, gina\@wsr.ac.at, Kl. 738\n" .
	    "Michael Demelbauer, michael\@wsr.ac.at, Kl. 787\n";
    return $msg;
}

my %opts;

sub sendmail
{
    my ($user, $msg, $mount) = @_;

    my @startgraph= 
	("/usr/local/dfstat/quotagraph",
	    "--fs=$mount",
	    "--user=$user",
	    "--data=b",
	    glob("/usr/local/dfstat/quota.stat.????-??")
	);
    if (system (@startgraph) != 0) {
	die "cannot execute @startgraph";
    }

    if ($opts{'d'}) {
	open (SENDMAIL, ">&1");
    } else {
	open (SENDMAIL, "|@@@sendmail@@@ -t -i");
    }
    if ($opts{'a'}) {
	print SENDMAIL "To: <system\@wsr.ac.at>\r\n";
	print SENDMAIL "Subject: User $user: Disk Quotas =?iso-8859-1?Q?=FCberschritten?=\r\n";
    } else {
	print SENDMAIL "To: <$user\@wsr.ac.at>\r\n";
	print SENDMAIL "Cc: <system\@wsr.ac.at>\r\n";
	print SENDMAIL "Subject: Disk Quotas =?iso-8859-1?Q?=FCberschritten?=\r\n";
       
    }
    print SENDMAIL "MIME-Version: 1.0\r\n";
    print SENDMAIL "Content-Type: text/plain; charset=iso-8859-1\r\n";
    print SENDMAIL "Content-Encoding: 8bit\r\n";
    print SENDMAIL "Reply-To: <system\@wsr.ac.at>\r\n";
    print SENDMAIL "\r\n";
    print SENDMAIL "$msg\r\n";
}

getopts('ad', \%opts);

$hostname=`hostname`;
chomp($hostname);
open (DF, "@@@df@@@ |") or die "cannot call @@@df@@@: $!";

my $fs = $/;
undef ($/);
my $df = <DF>;
close(DF);
$/ = $fs;

$df =~ s/\n[ \t]+/ /mg;
my @df = split(/\n/, $df); 
for my $ln (@df) {
    my ($fs, $total, $used, $free, $pct, $mount) = split(/\s+/, $ln);
    if ($fs =~ m|^/dev/|) {
	open REPQUOTA, "@@@repquota@@@ $mount 2>/dev/null |" or die "cannot call @@@repquota@@@: $!";
	while (<REPQUOTA>) {
	    next if ($. <= 2);	# ignore header lines
	    my $msg = "";
	    my $user;
	    if (/(\w+) \s+ -- \s*
	         (\d+)\s+(\d+)\s+(\d+)\s+
	         (\d+)\s+(\d+)\s+(\d+)
		 /x) {
		$user = $1;
		#print "ok: $1\n";
	    } elsif  (/(\w+) \s+ \+- \s*
	         (\d+)\s+(\d+)\s+(\d+)\s+(NOT\sSTARTED|EXPIRED|\d+\.\d+\ (?:days|hours))\s+
	         (\d+)\s+(\d+)\s+(\d+)
		 /x) {
		print "block limit: $1: $2 > ($3 $4) $5\n";
		$user = $1;
		$msg = warnmsg($mount, $2/1024, $3/1024, $4/1024, $5, "MB", $user);

	    } elsif  (/(\w+) \s+ -\+ \s*
	         (\d+)\s+(\d+)\s+(\d+)\s+
	         (\d+)\s+(\d+)\s+(\d+)\s+(NOT\sSTARTED|EXPIRED|\d+\.\d+\ (?:days|hours))
		 /x) {
		print "file limit: $1: $5 > ($6 $7) $8\n";
		$user = $1;
		$msg = warnmsg($mount, $5, $6, $7, $8, "Files", $user);
	    } elsif  (/(\w+) \s+ \+\+ \s*
	         (\d+)\s+(\d+)\s+(\d+)\s+(NOT\sSTARTED|EXPIRED|\d+\.\d+\ (?:days|hours))\s+
	         (\d+)\s+(\d+)\s+(\d+)\s+(NOT\sSTARTED|EXPIRED|\d+\.\d+\ (?:days|hours))
		 /x) {
		print "block limit: $1: $2 > ($3 $4) $5\n";
		$user = $1;
		$msg = warnmsg($mount, $2/1024, $3/1024, $4/1024, $5, "MB", $user);
		print "file limit: $1: $6 > ($7 $8) $9\n";
		$msg .= "\n\n" . warnmsg($mount, $6, $7, $8, $9, "Files", $user);
	    } else {
		print "$mount: $.: unparseable: $_";
		next;
	    }
	    if ($msg) {
		my $timestamp = "/usr/local/dfstat/quotacheck-timestamps/$user";

		if (!-e $timestamp) {
		    sendmail($user, $msg, $mount);	
		    open (PMSG, ">$timestamp")
			or die "cannot open $timestamp: $!";
		    print PMSG (@time);
		    close (PMSG);
		    
		    }
		else{
		    my $comp = -A $timestamp;
		    print STDERR "comp = $comp\n";
		    if ($comp > 5)
		    {
			sendmail($user, $msg, $mount);
		    }
		}
	    }
	    else{
	    	my @deletemsg = ("/usr/local/dfstat/quotacheck-timestamps/$user");
	    	unlink (@deletemsg);
	        }
	}
	close (REPQUOTA);
    }
}

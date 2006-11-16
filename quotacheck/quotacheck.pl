#!@@@perl@@@ -w 

use strict;

use Getopt::Std;
use Digest::MD5 qw(md5_hex);

my $time=time;
my @time=localtime($time);
my $hostname;

sub warnmsg {
    my ($mount, $usage, $soft, $hard, $grace, $unit, $user) = @_;
    my %dosdrv = (
	'/shares/common' => 'H:',
	'/wsrdb/users'	 => 'J:',
	'/shares/user'	 => 'K:',
	'/usr/local/www' => 'W:',
    );
    my $sunit = $unit eq "Files" ? "i" : "b";

    my $wo;
    if ($dosdrv{$mount}) {
	$wo = 'Netzplatte ' . $dosdrv{$mount};
    } else {
	$wo = "$mount (Host $hostname)";
    }


    my $msg = "Sie haben auf $wo Ihr in Disk Quotas gesetztes Limit\n" .
	    "überschritten. \n";
	    
    if ($grace eq "EXPIRED" or $grace eq "none" or $usage >= $hard-2) {
	$msg .= "Sie können dort KEINE Files mehr anlegen.\n" ;
    } else {
	$grace =~ s/ *days/ Tage/g;
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
	    "http://intra.wsr.ac.at/informationssysteme/quotas/$user${mount_t}_$sunit.png ansehen. \n" .
	    "Der Graph zeigten den verbrauchten Platz ('used') sowie die beiden\n" .
	    "Quotas ('soft' und 'hard')\n" .
	    "Die Softquota können Sie kurzfristig (noch $grace) überschreiten,\n" .
	    "die Hardquota nicht.\n" .
	    "\n" .
	    "Lassen Sie sich bei Gelegenheit auch von einem der zuständigen\n" .
	    "Systemadministratoren unterstützen:\n" .
	    "Gina Lanik, gina\@wsr.ac.at, Kl. 738\n" .
	    "Peter Holzer, hjp\@wsr.ac.at, Kl. 786\n" .
	    "Michael Demelbauer, michael\@wsr.ac.at, Kl. 787\n";

    my $timestamp = "/usr/local/dfstat/quotacheck-timestamps/$user:$mount_t:$sunit";

    if (!-e $timestamp) {
	sendmail($user, $msg, $mount);	
	open (PMSG, ">$timestamp")
	    or die "cannot open $timestamp: $!";
	print PMSG (@time);
	close (PMSG);
	
    } else {
	my $comp = -A $timestamp;
	#print STDERR "comp = $comp\n";
	if ($comp > 5) {
	    my $msg1 = $msg;
	    $msg1 =~ s/( noch \d)([.\d]*)( MB )/$1 . "x" x length($2) . $3/e;
	    $msg1 =~ s/(kurzfristig \(noch )([2-9])\d:\d\d\)/$1${2}0:00) /;
	    my $digest = md5_hex($msg1);
	    unless (-f "/var/tmp/quotacheck/$digest") {
		sendmail($user, $msg, $mount);
		mkdir("/var/tmp/quotacheck");
		my $f;
		open ($f, ">", "/var/tmp/quotacheck/$digest") && print $f "x";
	    }
	}
    }
}

my %opts;

sub sendmail
{
    my ($user, $msg, $mount) = @_;

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
    print SENDMAIL "MIME-Version: 1.0\r\n";
    print SENDMAIL "Content-Type: text/plain; charset=iso-8859-1\r\n";
    print SENDMAIL "Content-Transfer-Encoding: 8bit\r\n";
    print SENDMAIL "\r\n";
    print SENDMAIL "$msg\r\n";
}

sub parseline($$) {
    my ($mount, $line) = @_;
    local $_ = $line;
    my $hpuxtime = '(?:NOT\sSTARTED|EXPIRED|\d+\.\d+\ (?:days|hours))';
    my $linuxtime = '(?:none|\d+\:\d+|\d+days)';
    return undef unless (/\b\d+\b/);	# ignore header lines
    my $msg = "";
    my $user;
    if (/(\S+) \s+ -- \s*
	 (\d+)\s+(\d+)\s+(\d+)\s+
	 (\d+)\s+(\d+)\s+(\d+)
	 /x) {
	$user = $1;
	#print "ok: $1\n";
    } elsif  (/(\S+) \s+ \+- \s*
	 (\d+)\s+(\d+)\s+(\d+)\s+($hpuxtime|$linuxtime)\s+
	 (\d+)\s+(\d+)\s+(\d+)
	 /x) {
	#print "block limit: $1: $2 > ($3 $4) $5\n";
	$user = $1;
	$msg = warnmsg($mount, $2/1024, $3/1024, $4/1024, $5, "MB", $user);

    } elsif  (/(\S+) \s+ -\+ \s*
	 (\d+)\s+(\d+)\s+(\d+)\s+
	 (\d+)\s+(\d+)\s+(\d+)\s+($hpuxtime|$linuxtime)
	 /x) {
	#print "file limit: $1: $5 > ($6 $7) $8\n";
	$user = $1;
	$msg = warnmsg($mount, $5, $6, $7, $8, "Files", $user);
    } elsif  (/(\S+) \s+ \+\+ \s*
	 (\d+)\s+(\d+)\s+(\d+)\s+($hpuxtime|$linuxtime)\s+
	 (\d+)\s+(\d+)\s+(\d+)\s+($hpuxtime|$linuxtime)
	 /x) {
	#print "block limit: $1: $2 > ($3 $4) $5\n";
	$user = $1;
	$msg = warnmsg($mount, $2/1024, $3/1024, $4/1024, $5, "MB", $user);
	#print "file limit: $1: $6 > ($7 $8) $9\n";
	$msg .= "\n\n" . warnmsg($mount, $6, $7, $8, $9, "Files", $user);
    } else {
	print "$mount: $.: unparseable: $_";
	next;
    }
    return ($user, $msg);
}

getopts('adt', \%opts);

if ($opts{t}) {
    selftest();
}

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
	my $mount_t = $mount;
	$mount_t =~ s|/|_|g;
	open REPQUOTA, "@@@repquota@@@ $mount 2>/dev/null |" or die "cannot call @@@repquota@@@: $!";
	while (<REPQUOTA>) {
	    next unless (/\b\d+\b/);	# ignore header lines
	    my ($user, $msg) = parseline($mount, $_);
	}
	close (REPQUOTA);
    }
}


sub selftest {
    my $rc = 0;
    my ($user, $msg);

    ($user, $msg) = parseline("test", "haas      +- 1348620 1048576 2097152  41:48     296  3000  6000\n");
    unless ($user eq "haas" && $msg) {$rc = 1};

    exit($rc);
}

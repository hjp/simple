#!@@@perl@@@ -w
#
# $Id: agestat.pl,v 1.6 2006-02-17 13:31:41 hjp Exp $
#

use strict;
use File::stat;
use File::Find;
use Getopt::Long;

my $now = time();
my @bucket_max;

my %opts = (buckets => 'log2');
GetOptions(\%opts, "atime", "mtime", "scale=s", "buckets=s");
my $scale;
if (!defined($opts{scale})) {
    $scale = 1;
} elsif ($opts{scale} eq 'k') {
    $scale = 1024;
} elsif ($opts{scale} eq 'M') {
    $scale = 1024*1024;
} else {
    print STDERR "Usage: $0 [-atime|-mtime] [-scale=(k|M)]\n";
    exit 1;
}

if ($opts{buckets} eq "log2") {
    for (0 .. 31) {
	$bucket_max[$_] = 2 << $_;
    }
} elsif ($opts{buckets} eq "cal") {
    @bucket_max = (
	3600,
	86400,
	7 * 86400,
	30 * 86400,
	182 * 86400,
	1 * 365.2422 * 86400,
	2 * 365.2422 * 86400,
	3 * 365.2422 * 86400,
	4 * 365.2422 * 86400,
	5 * 365.2422 * 86400,
    );
}


my @hist;

sub wanted {

    my $st = lstat($_);
    my $age = $now - (
	$opts{atime} ? $st->atime :
	$opts{mtime} ? $st->mtime :
		       (! -d && $st->atime > $st->mtime ? $st->atime
		                                        : $st->mtime ));
    my $b = 0;
    while ($age > $bucket_max[$b]) { $b++ };
    #print $File::Find::name, ": $age sec, ", $st->size, " bytes, ", $st->nlink, " links, bucket $b\n";
    $hist[$b] += $st->size / $st->nlink;
}

sub time2str {
    my ($t) = (@_);

    if ($t < 60) {
	return sprintf ("%5.1f s", $t);
    } elsif ($t < 3600) {
	return sprintf ("%5.1f m", $t/60);
    } elsif ($t < 3600 * 24) {
	return sprintf ("%5.1f h", $t/3600);
    } elsif ($t < 3600 * 24 * 365.2422) {
	return sprintf ("%5.1f d", $t/(3600*24));
    } else {
	return sprintf ("%5.1f y", $t/(3600*24*365.2422));
    }
}



if (@ARGV == 0) { push (@ARGV, "."); }
find(\&wanted, @ARGV);

print "\n\n";

my $sum = 0;

for (my $i = 0; $i <= $#hist; $i++) {
    $sum += ($hist[$i] || 0);
}


my $c = 0;
for (my $i = 0; $i <= $#hist; $i++) {
    my $h = ($hist[$i] || 0);
    $c += $h;
    printf("%2d\t%s\t%12.0f\t%5.1f\t%12.0f\t%5.1f\n",
	   $i,
	   $i <= $#bucket_max ? time2str($bucket_max[$i]) : "infinity",
	   $h/$scale, $h * 100 / $sum, $c/$scale, $c * 100 / $sum);
}

# $Log: agestat.pl,v $
# Revision 1.6  2006-02-17 13:31:41  hjp
# Added option --buckets.
#
# Revision 1.5  2002/03/18 20:33:46  hjp
# Ignore atime for directories
#
# Revision 1.4  2001/01/19 19:06:01  hjp
# Removed superfluous "total" line.
# Fixed usage message.
#

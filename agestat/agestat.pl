#!@@@perl@@@ -w

use strict;
use File::stat;
use File::Find;
use Getopt::Long;

my $now = time();
my $log_2 = log(2);

my %opts = ();
GetOptions(\%opts, "atime", "mtime", "scale=s");
my $scale;
if (!defined($opts{scale})) {
    $scale = 1;
} elsif ($opts{scale} eq 'k') {
    $scale = 1024;
} elsif ($opts{scale} eq 'M') {
    $scale = 1024*1024;
} else {
    print STDERR "Usage: $0 [-atime|-mtime] [-scale=(k|m)]\n";
    exit 1;
}

my @hist;

sub wanted {

    my $st = lstat($_);
    my $age = $now - (
	$opts{atime} ? $st->atime :
	$opts{mtime} ? $st->mtime :
		       ($st->atime > $st->mtime ? $st->atime
		                                : $st->mtime ));
    #print $File::Find::name, ": $age sec, ", $st->size, " bytes, ", $st->nlink, " links\n";
    my $log2age = log($age >= 1 ? $age : 1) / $log_2;
    $hist[$log2age] += $st->size / $st->nlink;
}

sub logtime2str {
    my ($lt) = (@_);

    my $t = 1 << $lt;

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
    printf("%2d\t%s\t%12.0f\t%5.1f\t%12.0f\t%5.1f\n", $i,
	   logtime2str($i), $h/$scale, $h * 100 / $sum, $c/$scale, $c * 100 / $sum);
}
print("#-------------------------------------------\n");
printf("total\t\t%12.0f\t%5.1f\n",  $sum/$scale, $sum * 100 / $sum);

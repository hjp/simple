#!@@@perl@@@

#
# Report wasted space.
#
# This basically prints a list of files and directories below a 
# start point, where each entry is tagged with a "waste factor".
# The waste factor is a weighted sum of size, mtime and atime 
# of the file.
#

sub wastefactor {
    my ($size, $mtime, $atime) = @_;

    return $size * $sf * ($mtime * $mf + $atime * $af);
}


sub waste {
    my ($dir) = @_;
    my $i;
    my @files;
    my ($mtime, $atime, $size);
    my ($tmtime, $tatime, $tsize) = (0, 0, 0);

    if (!opendir(DIR, $dir)) {
	printf "$0: cannot open directory $dir: $!\n";
	return;
    }
    @files = readdir(DIR);
    closedir(DIR);
    foreach $i (@files) {
	if ($i eq "." || $i eq "..") { next }

	$filename = $dir . "/" . $i;
	($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,
	 $atime,$mtime,$ctime,$blksize,$blocks) =
		stat($filename); 

	if (-d _) {
	    ($size, $mtime, $atime) = waste($filename);
	} else {
	    printf "%10.0f %d %d %d %s\n",
	           wastefactor(
	           $size, ($now - $mtime), ($now - $atime)),
	           $size, ($now - $mtime), ($now - $atime),
		   $filename;
	}
	$tsize += $size;
	if ($mtime > $tmtime) {$tmtime = $mtime;}
	if ($atime > $tatime) {$tatime = $atime;}
    }
    printf "%10.0f %d %d %d %s\n",
	    wastefactor(
	    $tsize, ($now - $tmtime), ($now - $tatime)),
	    $tsize, ($now - $tmtime), ($now - $tatime),
	    $dir;
   return ($tsize, $tmtime, $tatime);
}

### --- main --- ###
$sf = 1.0/1000;
$mf = $af = 1.0/(3600*24*365.25);

if ($#ARGV != 0) {
    print "Usage: $0 directoryname\n";
    exit(1);
}

$now = time();

waste($ARGV[0]);
exit(0);

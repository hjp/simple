#!@@@perl@@@

use File::stat;
use File::Find;

$now = time();
$log_2 = log(2);

sub wanted {

    $st = lstat($_);
    $age = $now - ($st->atime > $st->mtime ? $st->atime : $st->mtime );
    #print $File::Find::name, ": $age sec, ", $st->size, " bytes, ", $st->nlink, " links\n";
    $log2age = log($age >= 1 ? $age : 1) / $log_2;
    $hist[$log2age] += $st->size / $st->nlink;
}

sub logtime2str {
    my ($lt) = (@_);

    $t = 1 << $lt;

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

$sum = 0;

for ($i = 0; $i <= $#hist; $i++) {
    $sum += $hist[$i];
}

for ($i = 0; $i <= $#hist; $i++) {
    $h = $hist[$i];
    $c += $h;
    printf("%2d\t%s\t%12.0f\t%5.1f\t%12.0f\t%5.1f\n", $i, logtime2str($i), $h, $h * 100 / $sum, $c, $c * 100 / $sum);
}
print("#-------------------------------------------\n");
printf("total\t\t%12.0f\t%5.1f\n",  $sum, $sum * 100 / $sum);

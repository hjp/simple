#!@@@perl@@@ -w
use strict;
use File::stat;
use POSIX;

my $verbose = 0;
my $nop = 0;

sub usage {
    print STDERR "Usage: $0 [-d days] dir ...\n";
    exit(1);
}

sub cleandir {
    my ($dir, $since, $level) = (@_);
    my $notremoved = 0;

    if ($verbose > 1) {
	print STDERR "$0:", " " x $level, " cleandir $dir $since {\n";
    }
    if (!opendir(DIR, ".")) {
	printf STDERR "$0:", " " x $level, " cannot opendir $dir: $!";
	return;
    }
    my $std = lstat(".");
    for my $i (readdir(DIR)) {
	if ($i eq "." || $i eq "..") {next}
	if ($verbose > 2) {
	    print STDERR "$0:", " " x $level, " checking $dir/$i\n";
	}
	my $st = lstat("$i");
	if ($verbose > 3) {
	    print STDERR "$0:", " " x $level, " mtime=", $st->mtime, " atime=", $st->atime, "\n";
	}
	if (-d _) {
	    my $cwd = getcwd();
	    if (chdir($i)) {
		my $remaining = -1;
		my $st1 = lstat(".");
		if ($st->dev == $st1->dev && $st->ino == $st1->ino) {
		    $remaining = cleandir("$dir/$i", $since, $level+1);
		} else {
		    print STDERR "$0:", " " x $level,
		    		 " $dir/$i changed dev/inode from ",
				 $st->dev, "/", $st->ino,
				 " to ",
				 $st1->dev, "/", $st1->ino,
				 "\n";
		}
		chdir($cwd);
		my $std1 = lstat(".");
		if (!($std->dev == $std1->dev && $std->ino == $std1->ino)) {
		    print STDERR "$0:", " " x $level,
		    		 " $cwd changed dev/inode from ",
				 $std->dev, "/", $std->ino,
				 " to ",
				 $std1->dev, "/", $std1->ino,
				 "\n";
		}
		if ($remaining == 0 && $st->mtime < $since) {
		    if ($verbose > 0) {
			print STDERR "$0:", " " x $level, "rmdir $i\n";
		    }
		    if (rmdir("$i")) {next}
		    print STDERR "$0:", " " x $level, "rmdir $i failed: $!\n";
		} 
	    } else {
		print STDERR "$0:", " " x $level, " chdir $dir/$i failed: $!\n";
	    }
	    
	} elsif ($st->mtime < $since && $st->atime < $since) {
	    if ($nop) {
		print "would remove $dir/$i\n";
	    } else {
		if ($verbose > 0) {
		    print STDERR "$0:", " " x $level, " removing $dir/$i\n";
		}
		if (unlink("$i")) {next}
		print STDERR "$0:", " " x $level, " removing $dir/$i failed: $!\n";
	    }
	    
	} 
	$notremoved++;
    }
    if ($verbose > 1) {
	print STDERR "$0:", " " x $level, " cleandir: $notremoved }\n";
    }
    return $notremoved;
}

sub main {
    my $since = time() - 14 * 86400;;
    my $i;
    while ($i = shift(@ARGV)) {
	if ($i eq "-d") {
	    my $days = shift(@ARGV);
	    $since = time() - $days * 86400;
	} elsif ($i eq "-v") {
	    $verbose++;
	} elsif ($i eq "-n") {
	    $nop++;
	} else {
	    my $cwd = getcwd();
	    if (chdir($i)) {
		cleandir($i, $since, 0);
		chdir($cwd);
	    }
	}
    }
    exit(0);
}

main();

# $Log: cleandir.pl,v $
# Revision 1.1  2001-06-25 17:55:03  hjp
# Added configure script to figure out perl location.
#
# Revision 1.4  2000/11/20 21:10:08  hjp
# Checks introduced in last version prevented deletion of unused subdirs.
# Fixed.
#
# revision 1.3
# date: 2000/09/10 16:16:41;  author: hjp;  state: Exp;  lines: +37 -6
# Added checks to detect directory/symlink switching attacks.
# ----------------------------
# revision 1.2
# date: 1999/08/21 12:37:53;  author: hjp;  state: Exp;  lines: +25 -13
# More levels of verbosity.
# ----------------------------
# revision 1.1
# date: 1999/07/09 21:05:26;  author: hjp;  state: Exp;
# Added cleandir
# 

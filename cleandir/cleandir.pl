#!@@@perl@@@ -w

=head1 NAME

cleandir - remove unused files from directory

=head1 SYNOPSIS

cleandir [-d days] [-n] [-m] [-v] [-s] directory...

=head1 DESCRIPTION

cleandir recursively searches each directory given on the commandline
for files and subdirectories which have not been accessed for n days and
deletes them. It is intended to be used on /tmp and other world-writable
directories and implements a number of checks to prevent symlink or
directory switching attacks. It also does not cross mount points.

=head1 OPTIONS

=over 4

=item B<-d days>

Delete files which have not been accessed for the given number of days.
The default is 14.

=item B<-m>

Consider only the last modification time of the file, not the last access time.

=item B<-n>

No-op. Don't delete any files.

=item B<-s>

Skip sockets and named pipes. Some programs (notably X11 and some
databases) create sockets and named pipes in /tmp and foolishly expect 
them to survive. This option exists to humour them.

=item B<-v>

Verbose. Can be repeated to increase verbosity.

=back

=head1 AUTHOR

Peter J. Holzer <hjp@hjp.at>. Thanks to Chris Mason for some
enhancements.

=cut

use strict;
use File::stat;
use POSIX;
use Getopt::Long;
use Pod::Usage;

my $verbose = 0;
my $nop = 0;
my $skip_fifos = 0;
my $mtime_only = 0;


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
    my $fs = $std->dev;

    for my $i (readdir(DIR)) {
	if ($i eq "." || $i eq "..") {next}
	if ($verbose > 2) {
	    print STDERR "$0:", " " x $level, " checking $dir/$i\n";
	}
	my $st = lstat("$i");

	# Skip anything on a different filesystem
	if ($st->dev != $fs) {
		$notremoved++;
		next;
	}

	# Skip sockets and pipes
	if ($skip_fifos && (-p _ || -S _)) {
		$notremoved++;
		next;
	}

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
		    return ++$notremoved;
		}
		if ($remaining == 0 && $st->mtime < $since) {
		    if ($verbose > 0) {
			print STDERR "$0:", " " x $level, "rmdir $i\n";
		    }
		    unless ($nop) {
			if (rmdir("$i")) {next}
			print STDERR "$0:", " " x $level, "rmdir $i failed: $!\n";
		    }
		} 
	    } else {
		print STDERR "$0:", " " x $level, " chdir $dir/$i failed: $!\n";
	    }
	    
	} elsif ($st->mtime < $since && ($st->atime < $since || $mtime_only)) {
	    if ($verbose > 0) {
		print STDERR "$0:", " " x $level, " removing $dir/$i\n";
	    }
	    unless ($nop) {
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
    my $help;

    GetOptions('help|?' => \$help,
               'days|d=f' => sub { $since = time() - $_[1] * 86400; },
               'verbose|v' => sub { $verbose++ },
	       'nop|n' => \$nop,
	       'skip-fifos|s' => \$skip_fifos,
	       'mtime-only|m' => \$mtime_only,
	      ) or pod2usage(2);
    pod2usage(1) if $help;
    pod2usage(2) unless (@ARGV);
    

    while ($i = shift(@ARGV)) {
	my $cwd = getcwd();
	if (chdir($i)) {
	    cleandir($i, $since, 0);
	    chdir($cwd);
	}
    }
    exit(0);
}

main();

# $Log: cleandir.pl,v $
# Revision 1.7  2004-11-02 09:01:12  hjp
# Critical bug fix: Empty directories were removed even with -n.
# Minor cleanup: Message "removing ..." is now the same with and without -n.
#
# Revision 1.6  2003/05/16 14:44:58  hjp
# Added -m option to synopsis.
#
# Revision 1.5  2003/05/16 13:38:25  hjp
# Included -m (mtime-only) option (CVS is nice, but only if it used).
# Improved pod a bit.
#
# Revision 1.4  2003/05/15 10:49:33  hjp
# Changed tests on skip_fifo to use _ instead of $i. The latter caused
# extra calls to stat which clobbered the state of _ which caused spurious
# errors/warnings on symlinks.
#
# Revision 1.3  2003/05/14 11:49:56  hjp
# Added yet another patch by Chris Mason.
#
# Added POD.
#
# Changed option processing to use Getopt::Long and Pod::Usage.
#
# Revision 1.2  2002/02/25 23:33:29  hjp
# Applied patch from "Chris L. Mason" <cmason@somanetworks.com> to prevent
# filesystem traversal.
#
# Return immediately if we cannot chdir back to the directory we came
# from.
#
# Revision 1.1  2001/06/25 17:55:03  hjp
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

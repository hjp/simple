#!@@@perl@@@ -w 
use strict;
use File::Find;
use Getopt::Long;

my $debug = 0;

sub check_cvs {
    local $/ =
    "===================================================================\n";
    return unless (-d "$_/CVS");
    print STDERR "checking $File::Find::dir/$_\n" if ($debug);

    # $_ is a CVS working dir

    open (CVSSTATUS, "cd $_ && cvs -q status|");
    while(<CVSSTATUS>) {
	print if  (/Status/ && !/Status: Up-to-date/);
    }
    close(CVSSTATUS);

    # don't recurse, cvs already did:
    $File::Find::prune = 1;
}

GetOptions("debug" => \$debug);
@ARGV = (".") unless (@ARGV);
find(\&check_cvs, @ARGV);

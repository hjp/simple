#!@@@perl@@@ -w

# $Id: oragetsrc.pl,v 1.2 2002-06-18 15:10:59 hjp Exp $
#
# print a named source (e.g, a function or procedure) from an oracle schema
#
use strict;
use DBI;

sub read_cred {
    my ($fn) = @_;

    open(FN, "<$fn") or die "cannot open $fn: $!";
    my $line = <FN>;
    close(FN);
    my @cred = split(/[\s\n]/, $line);
    return @cred;
}

if (@ARGV != 2) {
    print STDERR "Usage: $0 credential_file source_name\n";
    print STDERR "\tcredential_file is a filename relative to \$HOME/.dbi/\n";
    print STDERR "\tThe file must contain a single line with three whitespace-separated fields:\n";
    print STDERR "\tDBI data source, username, password.\n";
    print STDERR "\te.g:\n";
    print STDERR "\tdbi:Oracle:ORCL scott tiger\n";
    exit 1;
}


my $db_name = $ARGV[0];
my $src_name = $ARGV[1];

my @cred = read_cred("$ENV{HOME}/.dbi/$ARGV[0]");
my $dbh = DBI->connect($cred[0], $cred[1], $cred[2],
			    { RaiseError => 1, AutoCommit => 0 });

# check if it is a procedure or function
my $lines =
    $dbh->selectcol_arrayref(
	"select text from user_source where name=? order by line",
	{},
	$src_name
    );

if (@$lines) {
    for my $i (@$lines) {
	print "$i";
    }
    exit(0);
}

# nope - maybe a trigger?

$dbh->{LongReadLen} = 1000000;
$dbh->{LongTruncOk} = 0;
my $sth = $dbh->prepare("select description, trigger_body from user_triggers where trigger_name=?");
$sth->execute($src_name);
my $found = 0;
while (my $r = $sth->fetchrow_hashref("NAME_lc")) {
    print "TRIGGER ", $r->{description}, "\n", $r->{trigger_body}, "\n";;
    $found = 1;
}

exit(0) if ($found);

$dbh->disconnect();

exit(1);

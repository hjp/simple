#!@@@perl@@@ -w

# $Id: oragetsrc.pl,v 1.1 2001-02-12 14:32:43 hjp Exp $
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

my $lines =
    $dbh->selectcol_arrayref(
	"select text from user_source where name=? order by line",
	{},
	$src_name
    );

for my $i (@$lines) {
    print "$i";
}
$dbh->disconnect();


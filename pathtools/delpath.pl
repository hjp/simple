#!@@@perl@@@ -w

=head1 NAME

delpath - delete directories from path

=head1 SYNOPSIS

delpath [-v variable] directory...

=head1 DESCRIPTION

delpath deletes the directories given as arguments from the PATH and
prints the new path on stdout.

=head1 OPTIONS

=over 4

=item B<-v> I<variable>

Use the environment variable I<variable> instead of PATH.
This is useful for manipulating other PATH-like variables, like
LD_LIBRARY_PATH, PERL5LIB, etc.

=back

=head1 AUTHOR

Peter J. Holzer <hjp@hjp.at>.

=cut

use strict;
use Getopt::Long;
use Pod::Usage;

my $debug;
my $var = 'PATH';
GetOptions("debug" => \$debug,
           "var=s" => \$var,
          ) or pod2usage(2);

if ($#ARGV == 0 && $ARGV[0] =~ /:/) {
    @ARGV = split(/:/, $ARGV[0]);
}

my $path = $ENV{$var};
my @path = split(/:/, $path);

my %del;
for (@del{@ARGV}) {
    $_ = 1;
}

@path = grep { !$del{$_} } @path;

print join(':', @path), "\n";

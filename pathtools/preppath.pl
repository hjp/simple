#!@@@perl@@@ -w

=head1 NAME

preppath - prepend directories to path

=head1 SYNOPSIS

preppath [-c] [-v variable] directory...

=head1 DESCRIPTION

preppath prepends the directories given as arguments to the PATH,
eliminates  any duplicates and prints the new path on stdout. 

=head1 OPTIONS

=over 4

=item B<-c>

Check whether the directories exist before adding them. Nonexistent
directories are silently ignored.

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

my $check;
my $debug;
my $var = 'PATH';
GetOptions("check" => \$check,
           "debug" => \$debug,
           "var=s" => \$var,
          ) or pod2usage(2);

my $path = $ENV{$var} || '';
my @path = split(/:/, $path);

if ($#ARGV == 0 && $ARGV[0] =~ /:/) {
    @ARGV = split(/:/, $ARGV[0]);
}

my %seen;
my @newpath;

for my $d (@ARGV, @path) {
    if (!$seen{$d} && (!$check || -d $d)) {
	push @newpath, $d;
	$seen{$d} = 1;
    }
}
print join(':', @newpath), "\n";

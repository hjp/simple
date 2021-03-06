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

=item B<-e>

Print a complete export statement ready to be eval'd by a POSIX shell.

=item B<-p>

Print a complete variable assignment statement ready to be eval'd by a
POSIX shell. Unlike the C<-e> option this  does not prepend the export
keyword, so the variable is private unless it is exported elsewhere.

=item B<-r>

Reverse order of arguments. This is useful if you have several versions
of a software installed and you want the one with the highest version
number first in your path.

=back

=head1 AUTHOR

Peter J. Holzer <hjp@hjp.at>.

=cut

use strict;
use Getopt::Long;

my $check;
my $debug;
my $var = 'PATH';
my $export;
my $private;
my $reverse;
GetOptions("check"   => \$check,
           "debug"   => \$debug,
           "var=s"   => \$var,
           "export"  => \$export,
           "private" => \$private,
           "reverse" => \$reverse,
          ) or do {
                require Pod::Usage;
                import Pod::Usage;
                pod2usage(2);
            };

my $path = $ENV{$var} || '';
my @path = split(/:/, $path);

if ($#ARGV == 0 && $ARGV[0] =~ /:/) {
    @ARGV = split(/:/, $ARGV[0]);
}

if ($reverse) {
    @ARGV = reverse @ARGV;
}

my %seen;
my @newpath;

for my $d (@ARGV, @path) {
    if (!$seen{$d} && (!$check || -d $d)) {
	push @newpath, $d;
	$seen{$d} = 1;
    }
}

if ($export) {
    print "export ";
}
if ($export || $private) {
    print "$var=";
}
print join(':', @newpath), "\n";

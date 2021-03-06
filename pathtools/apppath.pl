#!@@@perl@@@ -w

=head1 NAME

apppath - append directories to path

=head1 SYNOPSIS

apppath [-c] [-v variable] directory...

=head1 DESCRIPTION

apppath appends the directories given as arguments to the PATH and
prints the new path on stdout.

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
GetOptions("check"   => \$check,
           "debug"   => \$debug,
           "var=s"   => \$var,
           "export"  => \$export,
           "private" => \$private,
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

nd: for my $nd (@ARGV) {
    for my $od (@path) {
	next nd if ($nd eq $od);
    }
    push @path, $nd if (!$check || -d $nd);
}
if ($export) {
    print "export ";
}
if ($export || $private) {
    print "$var=";
}
print join(':', @path), "\n";

#!@@@perl@@@ -w

=head1 NAME

preppath - prepend directories to path

=head1 SYNOPSIS

preppath [-c] directory...

=head1 DESCRIPTION

apppath prepends the directories given as arguments to the PATH,
eliminates  any duplicates prints the new path on stdout. 

=head1 OPTIONS

=over 4

=item B<-c>

Check whether the directories exist before adding them. Nonexistent
directories are silently ignored.

=back

=head1 AUTHOR

Peter J. Holzer <hjp@hjp.at>.

=cut

use strict;
my $path = $ENV{PATH};
my @path = split(/:/, $path);
my $check;

if ($ARGV[0] eq '-c') {
    $check = 1;
    shift;
}

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

#!@@@perl@@@ -w

=head1 NAME

apppath - append directories to path

=head1 SYNOPSIS

apppath [-c] directory...

=head1 DESCRIPTION

apppath appends the directories given as arguments to the PATH and
prints the new path on stdout.

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

nd: for my $nd (@ARGV) {
    for my $od (@path) {
	next nd if ($nd eq $od);
    }
    push @path, $nd if (!$check || -d $nd);
}
print join(':', @path), "\n";

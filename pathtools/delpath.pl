#!@@@perl@@@ -w

=head1 NAME

delpath - delete directories from path

=head1 SYNOPSIS

delpath directory...

=head1 DESCRIPTION

delpath deletes the directories given as arguments from the PATH and
prints the new path on stdout.

=head1 AUTHOR

Peter J. Holzer <hjp@hjp.at>.

=cut

use strict;

if ($#ARGV == 0 && $ARGV[0] =~ /:/) {
    @ARGV = split(/:/, $ARGV[0]);
}

my $path = $ENV{PATH};
my @path = split(/:/, $path);

my %del;
for (@del{@ARGV}) {
    $_ = 1;
}

@path = grep { !$del{$_} } @path;

print join(':', @path), "\n";

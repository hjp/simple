#!@@@perl@@@ -w

=head1 NAME

groupmatch - find best matching group for list of users

=head1 SYNOPSIS

groupmatch [--cut value] [--allmembers] [--debug] user ...

=head1 DESCRIPTION

This script takes a list of users and prints the group(s) which 
are the closest match (i.e. have the least number of missing or 
superfluous users).

For each group, the gid, group name, number of differences, and list of
users which are missing (marked (-)) or too much (+) is printed.

=head2 Options

=over 4

=item --cut value

Sets the cutoff value. Only groups with at most this number of
differences to the specified list of users are printed. By default the
cutoff value is set so that only the best matching group(s) are printed.

=item --allmembers

Prints all members of the group, not only the differences to the
specified list. Users which are already in the group are marked (*).

=item --debug

Prints some debug output to stderr.

=back

=head1 AUTHOR

Peter J. Holzer <hjp@wsr.ac.at>

=head1 SEE ALSO

id(1)

=cut

use strict;
use Getopt::Long;

sub diffsym {
    my ($diff) = @_;
    if ($diff == 0) { return "*"; }
    if ($diff < 0)  { return "-"; }
    if ($diff > 0)  { return "+"; }
    return "?";
}

my $cut = undef;
my $debug = 0;
my $allmembers = 0;
GetOptions("cut=i" => \$cut,
           "debug" => \$debug,
           "allmembers" => \$allmembers);
           

my $gr = {};

my @gr;
while (@gr = getgrent) {
    my ($name,$passwd,$gid,$members) = @gr;
    for my $i (split(/ /, $members)) {
	print STDERR "getgrent: $gid: $i\n" if($debug);
	$gr->{$gid}->{Members}->{$i} = 1;
	$gr->{$gid}->{Name} = $name;
    }
}
my @pw;
while (@pw = getpwent()) {
    my ($name,$passwd,$uid,$gid, $quota,$comment,$gcos,$dir,$shell,$expire) = @pw;
    print STDERR "getpwent: $gid: $name\n" if($debug);
    $gr->{$gid}->{Members}->{$name} = 1;

}
for my $g (keys %$gr) {
    for my $u (@ARGV) {
	$gr->{$g}->{Members}->{$u}--;
    }
    my $score = 0;
    for my $u (keys(%{$gr->{$g}->{Members}})) {
	$score += abs($gr->{$g}->{Members}->{$u});
    }
    print STDERR "$g: $score\n" if($debug);
    $gr->{$g}->{Score} = $score;
}
if ($debug) {
    print STDERR "\nScore list:\n";
    for my $g (keys %$gr) {
	print STDERR "$g: ", $gr->{$g}->{Score}, "\n";
    }
    print STDERR "\n";
}

for my $g (sort { $gr->{$a}->{Score} <=> $gr->{$b}->{Score} } keys %$gr) {
    $cut = $gr->{$g}->{Score} unless ($cut);
    next unless ($gr->{$g}->{Name});
    last if ($gr->{$g}->{Score} > $cut);

    print "$g: ",
           $gr->{$g}->{Name}, ": ",
           $gr->{$g}->{Score}, ": ";
    for my $u (sort keys(%{$gr->{$g}->{Members}})) {
	if ($allmembers || $gr->{$g}->{Members}->{$u}) {
	    print "$u(", diffsym($gr->{$g}->{Members}->{$u}), ") ";
	}
    }
    print "\n";
}

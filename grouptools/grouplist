#!/usr/local/bin/perl -w

=head1 NAME

groulist - list all members of a group

=head1 SYNOPSIS

grouplist [--fullname] group

=head1 DESCRIPTION

This script lists all members of a group.
For each user, the loginname, whether this is the primary or a supplemental group 
of the user, and optionally the full name (from the GECOS field) is printed.

=head2 Options

=over 4

=item --fullname

Print the GECOS field.

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

my $debug = 0;
my $fullname = 0;
GetOptions("debug" => \$debug,
           "fullname" => \$fullname);
           

my $u = {};

my @gr;
@gr = getgrnam($ARGV[0]);
unless (@gr) {
    print STDERR "$0: Group $ARGV[0] not found\n";
    exit(1);
}

my ($name,$passwd,$gid,$members) = @gr;
for my $i (split(/ /, $members)) {
    print STDERR "getgrent: $gid: $i\n" if($debug);
    $u->{$i}{s} = 1;
}

while (my @pw = getpwent()) {
    my ($name,$passwd,$uid,$ugid, $quota,$comment,$gcos,$dir,$shell,$expire) = @pw;
    print STDERR "getpwent: $ugid: $name\n" if($debug);
    if ($ugid == $gid) {
	$u->{$name}{p} = 1;
	$u->{$name}{fn} = $gcos;
    }
}

for my $i (keys %$u) {
    printf("%-10s %1s%1s", $i, $u->{$i}{p} ? "p" : " ", $u->{$i}{s} ? "s" : " ");
    if ($fullname) {
	if (!$u->{$i}{fn}) {
	    my @pw = getpwnam($i);
	    my ($name,$passwd,$uid,$ugid, $quota,$comment,$gcos,$dir,$shell,$expire) = @pw;
	    $u->{$i}{fn} = $gcos;
	}
	printf(" %s", $u->{$i}{fn});
    }
    print "\n";
}

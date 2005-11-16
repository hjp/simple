#!@@@perl@@@ -w

=head1 NAME

groupcount - count number of groups of all users

=head1 SYNOPSIS

groupcount

=head1 DESCRIPTION

This script counts the number of groups each user is a member of.

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
my $g = {};

while (my @gr = getgrent()) {

    my ($name,$passwd,$gid,$members) = @gr;
    $g->{$gid} = $name;
    for my $i (split(/ /, $members)) {
	print STDERR "getgrent: $gid: $i\n" if($debug);
	$u->{$i}{$name} = 1;
    }
}

while (my @pw = getpwent()) {
    my ($name,$passwd,$uid,$gid, $quota,$comment,$gcos,$dir,$shell,$expire) = @pw;
    $u->{$name}{$g->{$gid}} = 1;
    printf("%-10s %3d\n", $name, scalar(keys(%{$u->{$name}})));
}


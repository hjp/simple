#!/usr/bin/perl -w
use strict;
use Net::DNS;

sub usage {
    print STDERR "Usage: $0 domainname-or-ip-address\n";
    exit(1);
}

usage() unless (@ARGV == 1);

my $res = new Net::DNS::Resolver;
if ($ARGV[0] =~ m/^(\d+)\.(\d+)\.(\d+)\.(\d+)$/) {
    check_ptr($ARGV[0]);
} else {
    check_a($ARGV[0]);
    # check_ns($ARGV[0]);
}

exit 0;

my %addr_to_name;
my %name_to_addr;

sub check_ptr {
    my ($addr, $name) = @_;

    my @names;
    if (defined $addr_to_name{$addr}) {
        @names = @{ $addr_to_name{$addr} };
    } else {
        # XXX - ipv6?
        my $q = join('.', reverse (split(/\./, $addr)), "in-addr", "arpa");
        my $reply = $res->send($q, 'PTR');
        for my $ans ($reply->answer) {
            if ($ans->type eq 'PTR') {
                push @names, $ans->ptrdname;
            } else {
                die "cannot happen";
            }
        }
        if (@names == 0) {
            print "[$addr] $q has no PTR record\n";
        }
        $addr_to_name{$addr} = \@names;
    }
    if ($name) {
        unless (grep { $_ eq $name } @names) {
            print "$name not found in PTR records of [$addr]\n";
        }
        return;
    }
    for my $name (@names) {
        check_a($name, $addr);
    }
}

sub check_a {
    my ($name, $addr) = @_;

    my @addrs;
    if (defined $name_to_addr{$name}) {
        @addrs = @{ $name_to_addr{$name} };
    } else {
        my $reply = $res->send($name, 'A');
        for my $ans ($reply->answer) {
            if ($ans->type eq 'A') {
                push @addrs, $ans->address;
            } else {
                print "unexpected response to A query for $name\n";
		$ans->print;
            }
        }
        if (@addrs == 0) {
            print "$name has no A record\n";
        }
        $name_to_addr{$name} = \@addrs;
    }
    if ($addr) {
        unless (grep { $_ eq $addr } @addrs) {
            print "[$addr] not found in A records of $name\n";
        }
        return;
    }
    for my $addr (@addrs) {
        check_ptr($addr, $name);
    }
}

my $answer = $res->query($ARGV[0], $ARGV[1]);
if ($answer) {
    $answer->print;
} else {
    print STDERR "query failed: ", $res->errorstring, "\n";
}

# $res->nameservers($ARGV[2]);

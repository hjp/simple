#!/usr/bin/perl
use warnings;
use strict;
use Net::DNS;

sub usage {
    print STDERR "Usage: $0 domainname-or-ip-address\n";
    exit(1);
}

my $verbose;

if (($ARGV[0] || '') eq '-v') {
    $verbose = 1;
    shift @ARGV;
}

usage() unless (@ARGV == 1);

# generic resolver
my $res0 = new Net::DNS::Resolver;

# special resolver to query specific nameservers
my $res1 = new Net::DNS::Resolver;
my $zone;
if ($ARGV[0] =~ m/^(\d+)\.(\d+)\.(\d+)\.(\d+)$/) {
    check_ptr($ARGV[0]);
} else {
    check_a($ARGV[0]);
}
check_zone($ARGV[0]) if ($zone);

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
        my $reply = $res0->send($q, 'PTR');
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
	get_zone($reply) unless $zone;
    }
    if ($name) {
        unless (grep { $_ eq $name } @names) {
            print "$name not found in PTR records of [$addr]\n";
        }
        return;
    }
    for my $name (@names) {
	print "I: [$addr] -> $name\n" if $verbose;
        check_a($name, $addr);
    }
}

sub check_a {
    my ($name, $addr) = @_;

    my @addrs;
    if (defined $name_to_addr{$name}) {
        @addrs = @{ $name_to_addr{$name} };
    } else {
        my $reply = $res0->send($name, 'A');
        for my $ans ($reply->answer) {
            if ($ans->type eq 'A') {
                push @addrs, $ans->address;
	    } elsif ($ans->type eq 'CNAME') {
		die "cnames not yet supported";
            } else {
                print "unexpected response to A query for $name\n";
		$ans->print;
            }
        }
         if (@addrs == 0) {
            print "$name has no A record\n";
        }
        $name_to_addr{$name} = \@addrs;
	get_zone($reply) unless $zone;
    }
    if ($addr) {
        unless (grep { $_ eq $addr } @addrs) {
            print "[$addr] not found in A records of $name\n";
        }
        return;
    }
    for my $addr (@addrs) {
	print "I: $name -> [$addr]\n" if $verbose;
        check_ptr($addr, $name);
    }
}

sub get_zone {
    my ($reply) = @_;

    for my $auth ($reply->authority) {
	if (defined $zone) {
	    if ($zone ne $auth->name) {
		print "inconsistent authority RRs:\n";
		print $auth->print;
		print "doesn't match previously found zone $zone\n";
	    }
	} else {
	    $zone = $auth->name;
	}
    }
}

sub check_zone {
    my ($name) = @_;

    my $rootns = chr(rand(13) + 65) . ".root-servers.net.";
    my $reply = $res0->send($rootns, 'A');
    my @ns = (($reply->answer)[0]->address);
    my %authns;
    my %seen;
    while (@ns) {
	my $ns = shift (@ns);
	$res1->nameservers($ns);
	my $reply = $res1->send($zone, 'NS');

	# if the reply contains a non-empty answer section, use it as
	# a list of authoritative name servers.
	if ($reply->answer) {
	    for my $rr ($reply->answer) {
		if ($rr->type eq 'NS') {
		    print STDERR "$ns reported NS ", $rr->nsdname, "\n";;

		    $authns{$ns}{$rr->nsdname} = 1;
		    $authns{ALL}{$rr->nsdname} = 1;
		    for (get_addresses($rr->nsdname)) {
			unless ($seen{$_}) {
			    push @ns, $_;
			    $seen{$_} = 1;
			}
		    }
		}
	    }
	    next;
	}
	#
	if ($reply->authority) {
	    for my $rr ($reply->authority) {
		if ($rr->type eq 'NS') {
		    if ($rr->name eq $name) {
			# if the reply contains an authority section with the right
			# domain, use it as a list of authoritative name servers.
			print STDERR "$ns reported NS ", $rr->nsdname, "\n";;

			$authns{$ns}{$rr->nsdname} = 1;
			$authns{ALL}{$rr->nsdname} = 1;
			for (get_addresses($rr->nsdname)) {
			    unless ($seen{$_}) {
				push @ns, $_;
				$seen{$_} = 1;
			    }
			}
		    } else {
			# Otherwise, just add the nameservers from the authority section
			# to the list of nameservers still to query.
			for (get_addresses($rr->nsdname)) {
			    unless ($seen{$_}) {
				push @ns, $_;
				$seen{$_} = 1;
			    }
			}
		    }
		}
	    }
	    next;
	}

	
    }

    # We must make sure that we get a result from all authoritative
    # name servers
    #
    # XXX
    #
    # Isn't that included in the next test? If an authoritative
    # nameserver doesn't answer, it will be reported as not reporting 
    # all nameservers.

    # All lists of nameservers must be identical.
    #
    for my $authns (sort keys %{ $authns{ALL} }) {
	for my $origns (sort keys %authns) {
	    print "$origns doesn't report $authns\n" unless $authns{$origns}{$authns};
	}
    }

    my @noaxfr;
    my %zone;
    for my $authns (sort keys %{ $authns{ALL} }) {
	$res1->nameservers($authns);
	my @zone = $res1->axfr($zone);
	push @noaxfr, $authns unless @zone;
	for my $rr (@zone) {
	    my $key = rr2key($rr);

	    $zone{$authns}{$rr->name}{$rr->type}{$key} = 1;
	    $zone{ALL}{$rr->name}{$rr->type}{$key} = 1;
	}
    }
    for my $authns (@noaxfr) {
	$res1->nameservers($authns);
	for my $name (sort keys %{ $zone{ALL} }) {
	    for my $type (sort keys %{ $zone{ALL}{$name} }) {
		my $reply = $res1->send($name, $type);
		for my $rr ($reply->answer) {
		    if ($rr->type eq $type) {
			my $key = rr2key($rr);
			$zone{$authns}{$rr->name}{$rr->type}{$key} = 1;
			$zone{ALL}{$rr->name}{$rr->type}{$key} = 1;
		    }
		}
	    }
	}
    }
    for my $authns (sort keys %zone) {
	# next if $authns eq 'ALL';
	for my $name (sort keys %{ $zone{ALL} }) {
	    for my $type (sort keys %{ $zone{ALL}{$name} }) {
		for my $key (sort keys %{ $zone{ALL}{$name}{$type} }) {
		    unless ($zone{$authns}{$name}{$type}{$key}) {
			print STDERR "$authns is missing $name $type $key\n";
		    }
		}
	    }
	}
    }


}

sub get_addresses {
    my ($name) = @_;
    my @addrs;
    my $reply = $res0->send($name, 'A');
    for my $rr ($reply->answer) {
	if ($rr->type eq 'A') {
	    push @addrs, $rr->address;
	}
	# XXX - resolve CNAMEs?
    }
    return @addrs;
}

sub rr2key {
    my ($rr) = @_;

    my $key;

    if ($rr->type eq 'A') {
	$key = $rr->address;
    } elsif ($rr->type eq 'SOA') {
	$key = join(' ', $rr->mname, $rr->rname, $rr->serial, $rr->refresh, $rr->retry, $rr->expire, $rr->minimum);
    } elsif ($rr->type eq 'NS') {
	$key = $rr->nsdname;
    } elsif ($rr->type eq 'MX') {
	$key = join(' ', $rr->preference, $rr->exchange);
    } elsif ($rr->type eq 'CNAME') {
	$key = $rr->cname;
    } elsif ($rr->type eq 'TXT') {
	$key = $rr->txtdata;
    } elsif ($rr->type eq 'SRV') {
	$key = join(' ', $rr->priority, $rr->weight, $rr->port, $rr->target);
    } elsif ($rr->type eq 'PTR') {
	$key = $rr->ptrdname;
    } elsif ($rr->type eq 'HINFO') {
	$key = join(' ', $rr->cpu, $rr->os);
    } elsif ($rr->type eq 'LOC') {
	# sloppy
	my ($lat, $lon) = $rr->latlon;
	$key = join(' ', $lat, $lon, $rr->altitude);
    } else {
	print STDERR "unhandled RR:\n";
	print STDERR $rr->string, "\n";
	exit(1);
    }
    return $key;
}

# Notes:
# 
# for every a record, check ptr.
#
# for every ptr, check a
#
# find the zone (authority section).
#
# Check name servers (starting at random root).
#
# Try axfr.
# check each record:
#  the same on all nameservers?
#  A to PTR and vice versa
#  MX 
#
# vim: tw=0 sw=4 expandtab

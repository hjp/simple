#!/usr/bin/perl -w
use strict;
use Net::DNS;

my $res = new Net::DNS::Resolver;
$res->nameservers($ARGV[1]);
my @zone = $res->axfr($ARGV[0]);
if (@zone) {
    foreach my $rr (@zone) {
	$rr->print;
    }
} else {
    print STDERR "query failed: ", $res->errorstring, "\n";
}

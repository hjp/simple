#!/usr/bin/perl -wT
use strict;
use POSIX;
while (<>) {
    chomp;
    $now = strftime('%Y-%m-%dT%H:%M:%S', localtime);
    print "$now $_\n";
}

#!@@@perl@@@ -w
#
# $Id: cvsdiffmin.pl,v 1.1 2000-02-08 16:58:28 hjp Exp $
#
# cvsdiffmin - minimize output of cvs diff
#

use strict;

use File::Slurp;

my $diff = "@@@diff_format@@@";

my $state = 'EQ';
my %text = ();
my %cap = ();
my $count = 0;

local $| = 1;

while (<>) {

    if ($state eq 'EQ' && /^\<{7} /) {
	$state = 'V1';
	$text{$state} = "";
	s/'/_/g;
	$cap{$state} = $_;
	next;
    }
    if ($state eq 'V1' && /^\={7}$/) {
	$state = 'V2';
	$text{$state} = "";
	next;
    }
    if ($state eq 'V2' && /^\>{7} /) {
	s/'/_/g;
	$cap{$state} = $_;
	write_file("cvsdiffmin.$$.$count.1", $text{V1});
	write_file("cvsdiffmin.$$.$count.2", $text{V2});
	open (DIFF,
	    "$diff " .
	        " --unchanged-group-format='\%='" .
	        " --changed-group-format='${cap{V1}}\%<=======\n\%>${cap{V2}}'" .
	        " --old-group-format='${cap{V1}}\%<=======\n\%>${cap{V2}}'" .
	        " --new-group-format='${cap{V1}}\%<=======\n\%>${cap{V2}}'" .
		" cvsdiffmin.$$.$count.1" .
		" cvsdiffmin.$$.$count.2" .
		"|") or die "cannot invoke diff: $!";
	while (<DIFF>) {
	    print;
	}
	close(DIFF);

	
	$state = 'EQ';
	$count++;
	next;
    }
    if ($state eq 'EQ') {
	print;
    } else {
	$text{$state} .= $_;
    }
    
}

print "$state\n";

# vim:sw=4

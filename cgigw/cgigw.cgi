#!/usr/bin/perl
#
# $Id: cgigw.cgi,v 1.1 1998-04-28 22:01:23 hjp Exp $
#
# This is a simpe CGI gateway script.
#
# It can be used to access CGI scripts on a different server and/or
# port.
# Possible scenarios where this is useful:
# * Your real CGI scripts have to run on a machine behind a firewall.
#    In this case you may also want to modify this script to check
#    parameters.
# * Your real CGI scripts have to run on a different server (e.g., one 
#   with some special database installed), but you don't want to expose
#   that server's address in your URLs.
# * Your real CGI scripts have to run on a Web server which doesn't 
#   speak SSL.
#
# Usage: Change the customization section to point to the script which 
#        you really want to call. Install this script in some convenient
#        place. Make sure the target script generates only links to your
#        "official" server (If this is not possible, you might want to
#        tweak its output just before "print @rest;" at the very bottom
#        of this script.
#
# $Log: cgigw.cgi,v $
# Revision 1.1  1998-04-28 22:01:23  hjp
# Initial release.
# Only tested with a few CGIs and the Roxen web server.
#
#

use IO::Socket;

# BEGIN customization section
$serv_addr = "internal.host.com";
$serv_port = 80;
$serv_script = "/some/script.cgi";
# END customization section

$sock = IO::Socket::INET->new(PeerAddr => $serv_addr,
			      PeerPort => $serv_port);
if (!$sock) {
    print "Status: 500\r\n";
    print "Content-type: text/html\r\n";
    print "\r\n";
    print "<html><body>\n";
    print "<h1>Internal error</h1>\n";
    print "Connection to $serv_addr:$serv_port failed: $!\n";
    print "</body></html>\n";
}

$method = $ENV{REQUEST_METHOD};
$query_string = $ENV{QUERY_STRING};
print STDERR "$0: method = $method\n";

$sock->print("$method $serv_script");
if ($query_string ne "") {
    $sock->print("?$query_string");
}
$sock->print(" HTTP/1.0\r\n");
for $i (keys(%ENV)) {
    if ($i =~ m/^HTTP_(.*)/) {
	$key = $1;
	$key =~ s/_/-/g;
	$val = $ENV{$i};
	$sock->print("$key: $val\r\n");
	print STDERR "$0: Header: $key: $val\n";
    } else {
	$val = $ENV{$i};
	print STDERR "$0: Env: $i: $val\n";
    }
}
$content_length = $ENV{CONTENT_LENGTH};
if ($content_length) {
    $sock->print("Content-Length: ", $content_length, "\r\n\r\n");
    for ($i = 0; $i < $content_length; $i++) {
	read(STDIN, $c, 1);
	print STDERR "$0: Body: $i of $content_length: $c\n";
	$sock->print($c);
    }
    # padding:
    $sock->print("\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n");
} else {
    $sock->print("\r\n");
}
$sock->flush();
print STDERR "$0: Flushing\n";

$status = $sock->getline();
print STDERR "$0: Status: $status\n";
if ($status =~ m|^HTTP/\d+\.\d+ (\d+) |) {
    print "Status: $1\r\n";
} elsif ($status =~ m|:|) {
    # error: Assume this is a header and just pass it on
    print $status;
} else {
    # error: not a header. Assume this is HTML
    print "Content-Type: text/html\r\n";
    print "\r\n";
    print $status;
}
@rest = $sock->getlines;
print @rest;

print STDERR "$0: Finished\n";

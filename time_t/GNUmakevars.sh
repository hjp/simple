#!/bin/sh
prefix=${prefix:-/usr/local}
echo "BINDIR=$prefix/bin"

for i in "$prefix/share/man/man1" "$prefix/man/man1"
do
	if [ -d "$i" -a -w "$i" ]
	then
		echo "MAN1DIR=$i"
		break;
	fi
done

echo
echo "all:"

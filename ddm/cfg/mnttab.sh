#!/bin/sh
for i in /etc/mnttab /etc/mtab
do
    if [ -f $i ]
    then
	echo '#define MNTTAB "'$i'"'
	exit 0
    fi
done
exit 1

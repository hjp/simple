#!/bin/sh
while read a 
do
    x=$(date '+%Y-%m-%dT%H:%M:%S')
    echo "$x $a"
done

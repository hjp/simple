#!/bin/sh
if [ $# -eq 0 ]
then
    echo "Usage: $0 find-options" >&2
    exit 1
fi
@@@find_printf@@@ "$@" -type f -printf '%TY%Tm%Td%TH%TM.%TS %p\n' |
while read timestamp file
do
    : > "$file"
    touch -t "$timestamp" "$file"
done

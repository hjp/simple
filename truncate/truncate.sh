#!/bin/sh
@@@find_printf@@@ "$@" -type f -printf '%TY%Tm%Td%TH%TM.%TS %p\n' |
while read timestamp file
do
    echo -n "" > "$file"
    touch -t "$timestamp" "$file"
done

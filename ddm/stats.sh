#!/bin/sh

# simple statistics (min, avg, max) for ddm output

awk -F : '{ n[$4] ++; s[$4] += $3; if ($3 < min[$4]) min[$4] = $3; if ($3 > max[$4]) max[$4] = $3;  }
END { for (i in n) { printf "%10.6f %10.6f %10.6f %s\n", min[i], s[i]/n[i], max[i], i } }' "$@" | sort -n +2


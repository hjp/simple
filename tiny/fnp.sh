#!/bin/sh
@@@find@@@ "$@" -printf "%TY-%Tm-%Td %TH:%TM:%TS %6k %-8u %-8g %m %p\t%l\n"

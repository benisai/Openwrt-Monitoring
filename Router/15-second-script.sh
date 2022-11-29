#!/bin/sh
# set -x

cat /tmp/usage.htm | grep "2022" | sed 's/,/  /g; s/"//g; s/new Array//g' | tr -d '()'  > usage.out

#!/bin/sh

mkdir dump
./swish/dump2swish.pl
swish-e -c swish/common.conf -S fs
rm -fr dump

echo
echo "S�g med swish-search -f ../index/swish.index -w Foraar"
echo


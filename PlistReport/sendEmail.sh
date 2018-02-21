#!/bin/sh

echo "$(/bin/cat $1)" | /opt/local/bin/mutt -a $2 -s "Test Execution Result" -- $3



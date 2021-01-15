#!/bin/bash

REMOTE_VER=$( curl -s http://aj-alphabet.palladi.us/ 2>/dev/null | grep "AJ Alfabeto v. " | awk '{print $4}' )
CURRENT_VER=$(cat VERSION)


echo REMOTE VERSION: $REMOTE_VER
echo LOCAL VERSION: $CURRENT_VER

echo "TODO return 0 only if theyre different so you can use on Makefile to prepend a trigger to drain the cluster. #genius"
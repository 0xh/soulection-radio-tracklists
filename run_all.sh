#!/bin/bash
c=193
while [ $c -le 324 ]
do
  node process.js --episode=$c
  (( c++ ))
done

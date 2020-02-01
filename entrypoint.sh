#!/usr/bin/env bash

input_path=$1

echo "args: looking at $input_path"

fileslist=$(find $input_path -name "*.py" -type "f")

for x in $fileslist; do
    printf "%s\n" "looking at this file $x"
done

echo ::set-output name=fileslist::$fileslist

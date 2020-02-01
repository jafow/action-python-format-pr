#!/usr/bin/env bash

input_path=$1

if [[ -z "${input_path}" ]]; then
    input_path=`pwd`
fi

echo "args: looking at $input_path"

fileslist=$(find $input_path -name "*.py" -type "f")

# run black over the files list
black $fileslist

echo ::set-output name=fileslist::$fileslist

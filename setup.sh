#!/bin/sh

ABSOLUTE_PATH=$(cd $(dirname $0) && pwd)

for file in `find $ABSOLUTE_PATH  -maxdepth 1 -mindepth 1 -not \( -name README.md -o -name .git -o -name $(basename $0) \)`;
do
    ln -sf $file $HOME
done

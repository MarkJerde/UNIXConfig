#!/bin/bash
FROM=`pwd`
TO="$HOME"

for file in $(
echo .alias
echo .bashrc
echo .screenrc
echo .vimrc
) ; do
	echo Symbolic linking "$file"
	ln -s "$TO/$file" "$FROM/$file"
	ls -l "$TO/$file"
done

echo Done!


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
	if [ -f "$TO/$file" ]
	then
		echo Retaining default.
		mv "$TO/$file" "$TO/$file.default"
	fi
	ln -s "$TO/$file" "$FROM/$file"
	ls -l "$TO/$file"
done

echo Done!


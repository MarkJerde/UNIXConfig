#!/bin/bash
FROM=`pwd`
TO="$HOME"

for file in $(
echo .alias
echo .bashrc
echo .bash_profile
echo .screenrc
echo .vimrc
) ; do
	echo Symbolic linking "$file"
	if [ -f "$TO/$file" ]
	then
		echo Retaining default.
		mv "$TO/$file" "$TO/$file.default"
	fi
	ln -s "$FROM/$file" "$TO/$file"
	ls -l "$TO/$file"
done
if [ ! -e "$TO/bin" ] ; then mkdir "$TO/bin" ; fi
if [ ! -e "$TO/bin/ucbin" ] ; then ln -s "$FROM/bin" "$TO/bin/ucbin" ; fi

echo Done!


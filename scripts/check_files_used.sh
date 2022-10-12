#!/bin/bash

case "$2" in
  "used")
    commarg=-12
    ;;
  "unused")
    commarg=-23
    ;;
  "missing")
    commarg=-13
    ;;
esac

if [ -z "$commarg" ] || [ ! -d "$1" ] ; then
  echo "USAGE: $0 <folder> {used|unused|missing}" >&2
  exit 1
fi

folderpath="$(realpath --relative-to=. -- "$1")"/

comm $commarg \
  <(find ./"$folderpath" -type f | xargs realpath --relative-to=. -- | sort -u ) \
  <(grep -hPo '(?<=^INPUT ).*' ./*.fls | xargs realpath --relative-to=. -- | sort -u ) | \
  awk -v s="$folderpath" 'index($0, s) == 1'  # https://stackoverflow.com/a/43579906


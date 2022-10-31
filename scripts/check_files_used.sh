#!/bin/bash
set -eo pipefail

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

if [ -z "$commarg" ] || [ ! -d "$1" ] || [ -z "$3" ] ; then
  echo "USAGE: $0 <folder> {used|unused|missing} file1.tex [file2.tex ...]" >&2
  exit 1
fi

folderpath="$(realpath --relative-to=. -- "$1")"/

shift 2
flsfiles=()
for f in $@ ; do
  ff="${f%.tex}.fls"
  if [ ! -f "$ff" ] ; then
    echo "fls-file $ff not found. Maybe you need to run 'make most'?" >&2
    exit 2
  fi
  flsfiles+=("$ff")
done


comm $commarg \
  <(find ./"$folderpath" -type f | xargs realpath --relative-to=. -- | sort -u ) \
  <(perl -nle'print $& while m{(?<=^INPUT ).*}g' ${flsfiles[@]} | xargs realpath --relative-to=. -- | sort -u ) | \
  awk -v s="$folderpath" 'index($0, s) == 1'  # https://stackoverflow.com/a/43579906


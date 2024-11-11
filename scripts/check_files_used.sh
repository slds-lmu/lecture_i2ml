#!/bin/bash
set -eo pipefail
# This script checks which files are present in a given folder that were not used by a given set of tex-files.
# It does this by relying on *.fls-files, that are generated when tex is run with the 'record' option.
# The Makefile should do this when 'make most' is run.
#
# When a tex-file imports another file (e.g. a figure), the generated fls-file contains a line 'IMPORT <filename>'.
# This script compares the files listed in the given fls-files with the files that are present in a given folder.

# ------

# parse the 2nd command line argument first:
# if it is 'used', we list all the files that are used by tex files
# if it is 'unused', we list all files that are not used by tex files
# if is is 'missing', we list all files that the tex file wants to use but did not find.
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

# check command line arguments:
# $1 must be a directory
# $2 must have been parsed successfully above
# $3 must be given (as far as this check is concerned)
if [ -z "$commarg" ] || [ ! -d "$1" ] || [ -z "$3" ] ; then
  echo "USAGE: $0 <folder> {used|unused|missing} file1.tex [file2.tex ...]" >&2
  exit 1
fi

# normalize the path given to '$1' to be relative to the pwd
folderpath="$(realpath --relative-to=. -- "$1")"/

# drop the first two arguments:
# from here on, $1 will be the 3rd given argument, $2 will be the 4th given argument etc.
shift 2

# check if the fls-file for each given tex-file is present.
flsfiles=()
for f in $@ ; do
  ff="${f%.tex}.fls"
  if [ ! -f "$ff" ] ; then
    echo "fls-file $ff not found. Maybe you need to run 'make most'?" >&2
    exit 2
  fi
  flsfiles+=("$ff")
done

# here we use 'comm' to make a set-intersection:
# the options argument (commarg) tells us what we list:
#   '-12' would be set intersection
#   '-23' lists lines only in the content of 'FILE1' (i.e. files found in 'folderpath' but not in any fls-file
#   '-13' lists lines only in the content of 'FILE2'
# 'FILE1' (1st non-option argument) is the content of 'folderpath', normalized to be relative to pwd
# 'FILE2' (2nd non-option argument) is each line of the fls-files that starts with 'INPUT ', with the 'INPUT ' part removed.
#
# The 'awk' makes sure we only print lines that start with the 'folderpath' part.
# It is equivalent to `grep '^$folderpath'`, except that 'folderpath' could also contain regex special chars, so grep would not work.
comm $commarg \
  <(find ./"$folderpath" -type f | xargs realpath --relative-to=. -- | sort -u ) \
  <(perl -nle'print $& while m{(?<=^INPUT ).*}g' ${flsfiles[@]} | xargs realpath --relative-to=. -- | sort -u ) | \
  awk -v s="$folderpath" 'index($0, s) == 1'  # https://stackoverflow.com/a/43579906


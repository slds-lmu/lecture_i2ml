#!/bin/bash
set -eo pipefail
# This script checks which files are present in a given folder that were not used by a given set of tex-files.
# It does this by relying on *.fls-files, that are generated when tex is run with the 'record' option (latexmk -g).
# The Makefile should do this when 'make slides' is run.
#
# When a tex-file imports another file (e.g. a figure), the generated fls-file contains a line 'IMPORT <filename>'.
# This script compares the files listed in the given fls-files with the files that are present in a given folder.

# Detect platform and set appropriate realpath command
if [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS - use grealpath from GNU coreutils if available
  if command -v grealpath >/dev/null 2>&1; then
    REALPATH="grealpath"
  else
    echo "Error: GNU coreutils not found. Please install with: brew install coreutils" >&2
    exit 1
  fi
else
  # Linux/other - use standard realpath
  REALPATH="realpath"
fi

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
folderpath="$($REALPATH --relative-to=. -- "$1")"/

# drop the first two arguments:
# from here on, $1 will be the 3rd given argument, $2 will be the 4th given argument etc.
shift 2

# check if the fls-file for each given tex-file is present.
flsfiles=()
for f in "$@" ; do
  ff="${f%.tex}.fls"
  if [ ! -f "$ff" ] ; then
    echo "fls-file $ff not found. Maybe you need to run 'make slides'?" >&2
    exit 2
  fi
  flsfiles+=("$ff")
done

# Generate two sorted lists and compare them using 'comm':

# List 1: Files actually present in the specified folder
# List 2: Files referenced by LaTeX (from .fls files)

# Use 'comm' to compare two sorted lists line by line
# Note: The <(...) syntax is called "process substitution" - it runs the command
# inside the parentheses and makes the output appear as a temporary file that
# can be passed as an argument to another command. This avoids creating actual
# temporary files on disk.
#
# Think of it like this:
#   comm file1.txt file2.txt
# but where file1.txt and file2.txt are generated on-the-fly by commands
#
# FIRST LIST: Files actually present in the specified folder
# SECOND LIST: File references extracted from LaTeX .fls files, with these steps:
#   1. Extract all INPUT lines from .fls files and remove the "INPUT " prefix
#   2. Filter out TeXLive system files (e.g., /usr/local/texlive/.../package.sty) by excluding texmf-dist / texmf-var directories
#   3. Convert absolute paths to relative paths (suppress error messages)
#   4. Sort and remove duplicates to match format expected by 'comm'

comm "$commarg" \
  <(
    find ./"$folderpath" -type f | \
    xargs $REALPATH --relative-to=. -- | \
    sort -u
  ) \
  <(
    grep '^INPUT ' "${flsfiles[@]}" | sed 's/^INPUT //' | \
    grep -v -E '/(texmf-dist|texmf-var|texmf-local|texmf)/' | \
    xargs $REALPATH --relative-to=. -- 2>/dev/null | \
    sort -u
  ) | \
  awk -v s="$folderpath" 'index($0, s) == 1'

# The $commarg variable determines what we output:
#   '-12' = intersection (files in both lists) → used files
#   '-23' = files only in folder → unused files
#   '-13' = files only in LaTeX references → missing files


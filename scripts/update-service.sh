#! /bin/bash
# Download contents of lecture repos without cloning
# Intended for use in CI, where there is no need for a git history or $ git pull
# Downloading a tarball from the API is assumed to be faster than running `git clone`, even considering --depth 1 etc.

# Exit on error immediately
set -euo pipefail

# Use the main branch as default target or first argument $1 if specified
SERVICEBRANCH="${1:-main}" 
SERVICEURL="https://api.github.com/repos/slds-lmu/lecture_service/tarball/${SERVICEBRANCH}"
CURRENTDIR="$(basename $PWD)"
TEMPDIR=$(mktemp --directory)
CMD="curl -sL $SERVICEURL | tar -xz --directory=$TEMPDIR --strip-components=1"

if [[ "$CURRENTDIR" == lecture_service ]]
then
  echo -e "! This script should be run in the lecture repo (e.g. lecture_i2ml), \033[1mnot\033[22m the service repo!"
  exit 1
fi


if [[ "$CURRENTDIR" != lecture_* ]]
then
  echo "! This does not look like a lecture repo!"
  echo -e "! Make sure your current working directory is e.g. \033[1mlecture_i2ml\033[22m, rather than a subdirectory."
  exit 1
fi

if [[ ! -d $TEMPDIR ]]
then
  echo "! Could not create temporary download dir, aborting!"
  exit 1
fi

echo -e "- Updating service components from  \033[1m\"$SERVICEBRANCH\"\033[22m branch using"
echo "    URL: $SERVICEURL"
echo "    Temporary download directory: $TEMPDIR"
echo ""
echo -e "\033[33m⚠️  WARNING: The ./style/ directory will be completely synchronized with upstream.\033[0m"
echo -e "\033[33m   Any local files in ./style/ not present in lecture_service will be REMOVED!\033[0m"
echo ""
echo "- Running: "
echo -e "    $CMD"
eval "$CMD"


# Note that using e.g. cp -r .../service/* would not include .-files as they are not expanded by *
# using cp -r .../service/ on linux copied the service dir itself, hence using rsync for correct behavior
echo "- Syncing contents of $TEMPDIR/service to ${PWD}"
# First, sync everything except style/ directory
rsync -a --exclude='style/' "$TEMPDIR/service/" .

# Then sync style/ directory with --delete to remove files not in upstream
# This ensures style/ is 100% derived from lecture_service
if [[ -d "$TEMPDIR/service/style" ]]; then
  echo "- Syncing ./style/ directory (removing files not in upstream)"
  rsync -a --delete "$TEMPDIR/service/style/" ./style/
else
  echo "⚠️  Warning: style/ directory not found in upstream"
fi

echo "- Deleting temporary download directory"
rm -r "$TEMPDIR"

echo ""
echo "-- Done! --"
echo "-> Please review changes carefully to avoid unintentional changes."

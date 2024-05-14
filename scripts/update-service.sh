#! /bin/bash
# Download contents of lecture repos without cloning
# Intended for use in CI, where there is no need for a git history or $ git pull
# Downloading a tarball from the API is assumed to be faster than running `git clone`, even considering --depth 1 etc.


SERVICEURL="https://api.github.com/repos/slds-lmu/lecture_service/tarball/main"
CURRENTDIR="$(basename $PWD)"
TEMPDIR=$(mktemp --directory)
CMD="curl -sL $SERVICEURL | tar -xz --directory=$TEMPDIR --strip-components=1"

if [[ $CURRENTDIR == lecture_service ]]
then
  echo "! This script should be run in the lecture repo (e.g. lecture_i2ml), \033[1mnot\033[22m the service repo!"
  exit 1
fi


if [[ $CURRENTDIR != lecture_* ]]
then
  echo "! This does not look like a lecture repo!"
  echo "! Make sure your current working directory is e.g. \033[1mlecture_i2ml\033[22m, rather than a subdirectory."
  exit 1
fi

if [[ ! -d $TEMPDIR ]]
then
  echo "! Could not create temporary download dir exists, aborting!"
  exit 1
fi

echo "- Updating service components from https://github.com/slds-lmu/lecture_service/tree/main/service"
echo "- Running: "
echo "  $CMD"
eval "$CMD"

# Note that using e.g. .../service/* would not include .-files as they are not expanded by *
echo "- Moving contents of service dir to ${PWD}"
cp -r "$TEMPDIR/service/" .
echo "- Deleting temporary download directory"
rm -r "$TEMPDIR"

echo ""
echo "-- Done! --"
echo "-> Please review changes carefully to avoid unintentional changes."

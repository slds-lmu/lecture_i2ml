#! /bin/bash
# Download contents of lecture repos without cloning
# Intended for use in CI, where there is no need for a git history or $ git pull
# Downloading a tarball from the API is assumed to be faster than running `git clone`, even considering --depth 1 etc.

# Exit on error immediately
set -euo pipefail

# Use the main branch as default target or first argument $1 if specified
SERVICEBRANCH="${1:-main}"
SERVICEURL="https://api.github.com/repos/slds-lmu/lecture_service/tarball/${SERVICEBRANCH}"
CURRENTDIR="$(basename "$PWD")"

# Create temp directory (portable for Linux and macOS)
if command -v mktemp >/dev/null 2>&1; then
    # Try GNU mktemp (Linux) syntax first
    TEMPDIR=$(mktemp -d 2>/dev/null) || TEMPDIR=$(mktemp -d -t lecture-service.XXXXXX)
else
    echo "Error: mktemp not found"
    exit 1
fi

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

if [[ ! -d "$TEMPDIR" ]]
then
  echo "Error: Could not create temporary directory"
  exit 1
fi

# Ensure cleanup on exit
# trap runs the cleanup function when the script exits (normally or via Ctrl+C)
cleanup() {
    if [ -n "${TEMPDIR:-}" ] && [ -d "$TEMPDIR" ]; then
        rm -rf "$TEMPDIR"
    fi
}
trap cleanup EXIT INT TERM

echo -e "- Updating service components from  \033[1m\"$SERVICEBRANCH\"\033[22m branch using"
echo "    URL: $SERVICEURL"
echo "    Temporary download directory: $TEMPDIR"
echo ""
echo "WARNING: The ./style/ directory will be completely synchronized with upstream."
echo "         Any local files in ./style/ not present in lecture_service will be REMOVED!"
echo ""

# Download tarball to file first (more robust than piping)
TARBALL="$TEMPDIR/archive.tar.gz"
echo "Downloading archive from GitHub..."

if ! curl -L -f -o "$TARBALL" "$SERVICEURL" 2>/dev/null; then
    echo "Error: Failed to download archive. Branch '$SERVICEBRANCH' may not exist."
    exit 1
fi

# Extract with better error handling
echo "Extracting archive..."
if ! tar -xzf "$TARBALL" -C "$TEMPDIR" --strip-components=1 2>/dev/null; then
    # Try alternative extraction method
    if command -v gunzip >/dev/null 2>&1; then
        gunzip -c "$TARBALL" | tar -xf - -C "$TEMPDIR" --strip-components=1 || {
            echo "Error: Failed to extract archive. File may be corrupted."
            exit 1
        }
    else
        echo "Error: Failed to extract archive"
        exit 1
    fi
fi


# Verify extraction succeeded
if [ ! -d "$TEMPDIR/service" ]; then
    echo "Error: Expected 'service' directory not found in extracted archive"
    exit 1
fi

# Note that using e.g. cp -r .../service/* would not include .-files as they are not expanded by *
# using cp -r .../service/ on linux copied the service dir itself, hence using rsync for correct behavior
echo "Syncing files to current directory..."
# First, sync everything except style/ directory
rsync -a --exclude='style/' "$TEMPDIR/service/" .

# Then sync style/ directory with --delete to remove files not in upstream
# This ensures style/ is 100% derived from lecture_service
if [[ -d "$TEMPDIR/service/style" ]]; then
  echo "Syncing ./style/ directory (removing files not in upstream)"
  rsync -a --delete "$TEMPDIR/service/style/" ./style/
else
  echo "Warning: style/ directory not found in upstream"
fi

echo ""
echo "Done! Please review changes carefully."
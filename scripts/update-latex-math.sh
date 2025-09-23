#!/bin/bash
# Download contents of latex-math repo without cloning
# Intended for use in CI and local development
# Downloading a tarball from the API is assumed to be faster than running `git clone`

# Exit on error immediately
set -euo pipefail

# Use the master branch as default target or first argument $1 if specified
BRANCH="${1:-master}"
MATHURL="https://api.github.com/repos/slds-lmu/latex-math/tarball/${BRANCH}"

# Create temp directory (portable for Linux and macOS)
if command -v mktemp >/dev/null 2>&1; then
    # Try GNU mktemp (Linux) syntax first
    TEMPDIR=$(mktemp -d 2>/dev/null) || TEMPDIR=$(mktemp -d -t latex-math.XXXXXX)
else
    echo "Error: mktemp not found"
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

echo "Updating latex-math from slds-lmu/latex-math repository..."
echo "  Branch: ${BRANCH}"
echo "  URL: ${MATHURL}"
echo "  Temporary download directory: ${TEMPDIR}"
echo ""
echo "WARNING: The ./latex-math/ directory will be completely synchronized with upstream."
echo "         Any local files in ./latex-math/ not present in slds-lmu/latex-math will be REMOVED!"
echo ""

# Download tarball to file first (more robust than piping)
TARBALL="$TEMPDIR/archive.tar.gz"
echo "Downloading archive from GitHub..."

if ! curl -L -f -o "$TARBALL" "$MATHURL" 2>/dev/null; then
    echo "Error: Failed to download archive. Branch '$BRANCH' may not exist."
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

# Remove unnecessary files before syncing
echo "Removing unnecessary files from downloaded content..."
rm -f "$TEMPDIR/latex-math.pdf"
rm -f "$TEMPDIR/latex-math.Rmd"
rm -rf "$TEMPDIR/.github"

# Sync latex-math directory with --delete to ensure exact match with upstream
echo "Syncing ./latex-math/ directory (removing files not in upstream)..."
mkdir -p latex-math  # Ensure directory exists
rsync -a --delete "$TEMPDIR/" ./latex-math/

echo ""
echo "Done! latex-math updated successfully."
echo "Please review changes carefully."
#!/bin/bash
# Download contents of latex-math repo without cloning
# Intended for use in CI and local development
# Downloading a tarball from the API is assumed to be faster than running `git clone`

# Exit on error immediately
set -euo pipefail

# Use the master branch as default target or first argument $1 if specified
BRANCH="${1:-master}"
MATHURL="https://api.github.com/repos/slds-lmu/latex-math/tarball/${BRANCH}"
TEMPDIR=$(mktemp --directory)

if [[ ! -d $TEMPDIR ]]
then
  echo "! Could not create temporary download dir, aborting!"
  exit 1
fi

echo "Updating latex-math from slds-lmu/latex-math repository..."
echo "  Branch: ${BRANCH}"
echo "  URL: ${MATHURL}"
echo "  Temporary download directory: ${TEMPDIR}"
echo ""
echo -e "\033[33m⚠️  WARNING: The ./latex-math/ directory will be completely synchronized with upstream.\033[0m"
echo -e "\033[33m   Any local files in ./latex-math/ not present in slds-lmu/latex-math will be REMOVED!\033[0m"
echo ""

# Download and extract latex-math to temp directory
echo "- Downloading and extracting latex-math to temp directory..."
curl -sL "${MATHURL}" | tar -xz --directory="${TEMPDIR}" --strip-components=1

# Remove unnecessary files before syncing
echo "- Removing unnecessary files from downloaded content..."
rm -f "${TEMPDIR}/latex-math.pdf"
rm -f "${TEMPDIR}/latex-math.Rmd"
rm -rf "${TEMPDIR}/.github"

# Sync latex-math directory with --delete to ensure exact match with upstream
echo "- Syncing ./latex-math/ directory (removing files not in upstream)..."
mkdir -p latex-math  # Ensure directory exists
rsync -a --delete "${TEMPDIR}/" ./latex-math/

echo "- Deleting temporary download directory"
rm -r "${TEMPDIR}"

echo ""
echo "-- Done! --"
echo "latex-math updated successfully"
echo "-> Please review changes carefully to avoid unintentional changes."
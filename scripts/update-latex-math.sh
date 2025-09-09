#!/bin/bash
# Download contents of latex-math repo without cloning
# Intended for use in CI and local development
# Downloading a tarball from the API is assumed to be faster than running `git clone`

# Exit on error immediately
set -euo pipefail

# Use the master branch as default target or first argument $1 if specified
BRANCH="${1:-master}"
MATHURL="https://api.github.com/repos/slds-lmu/latex-math/tarball/${BRANCH}"

echo "Updating latex-math from slds-lmu/latex-math repository..."
echo "  Branch: ${BRANCH}"
echo "  URL: ${MATHURL}"

# Remove old latex-math contents to ensure outdated files are removed
echo "- Removing old latex-math contents..."
rm -rf latex-math/*

# Download and extract latex-math
echo "- Downloading and extracting latex-math..."
curl -sL "${MATHURL}" | tar -xz --directory=latex-math/ --strip-components=1

# Remove unnecessary files to avoid dragging large binary blobs through git history
echo "- Removing unnecessary files..."
rm -f latex-math/latex-math.pdf
rm -f latex-math/latex-math.Rmd
rm -rf latex-math/.github

echo ""
echo "-- Done! --"
echo "latex-math updated successfully"
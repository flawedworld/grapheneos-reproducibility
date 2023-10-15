#!/usr/bin/env bash

set -o errexit -o pipefail

# Set default values 
BUILD_AUDITOR="${BUILD_AUDITOR:-no}"
BUILD_APPS="${BUILD_APPS:-no}" 
BUILD_CAMERA="${BUILD_CAMERA:-no}" 
BUILD_PDFVIEWER="${BUILD_PDFVIEWER:-no}" 
BUILD_TALKBACK="${BUILD_TALKBACK:-no}" 
BUILD_GMSCOMPAT="${BUILD_GMSCOMPAT:-no}"

AUDITOR_MANIFEST="${AUDITOR_MANIFEST:-latest}"
APPS_MANIFEST="${APPS_MANIFEST:-latest}"
CAMERA_MANIFEST="${CAMERA_MANIFEST:-latest}"
PDFVIEWER_MANIFEST="${PDFVIEWER_MANIFEST:-latest}"
# TALKBACK_MANIFEST="${TALKBACK_MANIFEST:-latest}"
GMSCOMPAT_MANIFEST="${GMSCOMPAT_MANIFEST:-latest}"

GIT_USERNAME="${GIT_USERNAME:-grapheneos}"
GIT_EMAILADDRESS="${GIT_EMAILADDRESS:-grapheneos-build@localhost}"

# Configure Git user name and email and gitcookies
git config --global user.name "$GIT_USERNAME"
git config --global user.email "$GIT_EMAILADDRESS"

if [ -f "/.gitcookies" ]; then
    git config --global http.cookiefile /.gitcookies
fi

source install_sdk.sh
source build_applications.sh

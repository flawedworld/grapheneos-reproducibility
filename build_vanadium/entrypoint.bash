#!/bin/bash

set -o errexit -o pipefail

# Set default values 
VANADIUM_MANIFEST="${VANADIUM_MANIFEST:-""}"
GIT_USERNAME="${GIT_USERNAME:-grapheneos}"
GIT_EMAILADDRESS="${GIT_EMAILADDRESS:-grapheneos-build@localhost}"

# Configure Git user name and email and gitcookies
git config --global user.name "$GIT_USERNAME"
git config --global user.email "$GIT_EMAILADDRESS"

if [ -f "/.gitcookies" ]; then
    git config --global http.cookiefile /.gitcookies
fi

source build_vanadium.sh $VANADIUM_MANIFEST

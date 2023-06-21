#!/bin/bash

set -o errexit -o pipefail

# Set default values 
APPS_TO_BUILD="${APPS_TO_BUILD:-all}"
MANIFEST="${MANIFEST:-all}"
GIT_USERNAME="${GIT_USERNAME:-grapheneos}"
GIT_EMAILADDRESS="${GIT_EMAILADDRESS:-grapheneos-build@localhost}"

# Configure Git user name and email and gitcookies
git config --global user.name "$GIT_USERNAME"
git config --global user.email "$GIT_EMAILADDRESS"

if [ -f "/.gitcookies" ]; then
    git config --global http.cookiefile /.gitcookies
fi
IFS=" " read -ra apps_array <<< "$APPS_TO_BUILD"
# Function to check breaking environment conditions
check_breaking_env() {
    IFS=" " read -ra apps_array <<< "$APPS_TO_BUILD"

    # If we want to build the applications and we don't have what applications to build...
    if [[ -z $APPS_TO_BUILD ]]; then
        echo "If you want to build the applications, ensure that you set APPS_TO_BUILD to what you want to build. If you want to build all, set the variable to all."
        exit 1
    fi

    # For any potential application in APPS_TO_BUILD, check to see if they are acceptable values.
    for app in "${apps_array[@]}"; do
        app=${app//\"/}
        if [[ $app != "Auditor" && $app != "Apps" && $app != "Camera" && $app != "PdfViewer" && $app != "TalkBack" && $app != "GmsCompat" && $app != "all" ]]; then
            echo "$app is not a valid application. The only valid applications are: Auditor, Apps, Camera, PdfViewer, TalkBack, GmsCompat. You can also set it to 'all' and it will build all the applications."
            exit 1
        fi
    done
}

check_breaking_env

source install_sdk.sh
source build_applications.sh $MANIFEST

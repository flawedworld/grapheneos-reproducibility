#!/bin/bash

set -o errexit -o pipefail

# Set default values 
DEVICES_TO_BUILD="${DEVICES_TO_BUILD:-"raven"}"
BUILD_TARGET="${BUILD_TARGET:-"stable"}"
BUILD_NUMBER="${BUILD_NUMBER:-""}"
BUILD_DATETIME="${BUILD_DATETIME:-""}"
BUILD_ID="${BUILD_ID:-""}"
USE_PREBUILT_APPS="${USE_PREBUILT_APPS:-"true"}"
USE_PREBUILT_KERNEL="${USE_PREBUILT_KERNEL:-"true"}"
USE_PREBUILT_VANADIUM="${USE_PREBUILT_VANADIUM:-"true"}"
NPROC_SYNC="${NPROC_SYNC:-8}"
NPROC_BUILD="${NPROC_BUILD:-8}"
GIT_USERNAME="${GIT_USERNAME:-grapheneos}"
GIT_EMAILADDRESS="${GIT_EMAILADDRESS:-grapheneos-build@localhost}"

# Configure Git user name and email and gitcookies
git config --global user.name "$GIT_USERNAME"
git config --global user.email "$GIT_EMAILADDRESS"

if [ -f "/.gitcookies" ]; then
    git config --global http.cookiefile /.gitcookies
fi

# Function to check breaking environment conditions
check_breaking_env() {
    IFS=" " read -r -a device_array <<< "$DEVICES_TO_BUILD"

    # If this isn't build method one...
    if [[ -z $BUILD_TARGET ]]; then
        # If this isn't build method three...
        if [[ -z $BUILD_NUMBER || -z $BUILD_DATETIME || -z $BUILD_ID ]]; then
            echo "Cannot run: there must be an equal amount of devices to manifests unless you specify BUILD_TARGET=stable OR you specify BUILD_NUMBER and BUILD_DATETIME and BUILD_ID."
            exit 1
        fi
    else
        # If this is a combination of build method one and three...
        if [[ ! -z $BUILD_NUMBER || ! -z $BUILD_DATETIME || ! -z $BUILD_ID ]]; then
            echo "You have specified a BUILD_NUMBER, BUILD_DATETIME, and BUILD_ID as well as a BUILD_TARGET. BUILD_TARGET is for one-off builds of the latest builds and development builds directly from git."
            exit 1
        fi
    fi

    # If the BUILD_TARGET exists and is not an acceptable value...
    elif [[ $BUILD_TARGET != "stable" && $BUILD_TARGET != "beta" && $BUILD_TARGET != "alpha" && $BUILD_TARGET != "testing" && ! -z $BUILD_TARGET ]]; then
        echo "BUILD_TARGET can currently only be set to stable, beta, alpha, or testing."
        exit 1
    fi

    # For any potential devices in DEVICES_TO_BUILD, check to see if they are acceptable values.
    for device in "${device_array[@]}"; do
        device=${device//\"/}
        if [[ $device != "coral" && $device != "sunfish" && $device != "bramble" && $device != "redfin" && $device != "barbet" && $device != "oriole" && $device != "raven" && $device != "bluejay" && $device != "panther" && $device != "cheetah" && $device != "lynx" && $device != "tangorpro" ]]; then
            echo "$device is not a valid device. The only valid devices are: coral, sunfish, bramble, redfin, barbet, oriole, raven, bluejay, panther, cheetah, lynx, and tangorpro."
            exit 1
        fi
    done
}

# Ping the official update server and get the current metadata.
get_metadata () {
    local DEVICE=$1
    local CHANNEL=$2

    URL="https://releases.grapheneos.org/${DEVICE}-${CHANNEL}"

    read -r BUILD_NUMBER BUILD_DATETIME BUILD_ID _ < <(echo $(curl -s $URL))

    export BUILD_NUMBER="$BUILD_NUMBER"
    export BUILD_DATETIME="$BUILD_DATETIME"
    export BUILD_ID="$BUILD_ID"
    export MANIFEST_FROM_METADATA="${BUILD_ID}.${BUILD_NUMBER}"
}

check_breaking_env

for ((i = 0; i < ${#device_array[@]}; i++)); do

    # This is for the case of "I have a BUILD_NUMBER, BUILD_DATETIME and BUILD_ID and I don't want to check against BUILD_TARGET".
    if [[ -z $BUILD_TARGET ]]; then
        source compile_os.sh "${device_array[i]}" "$BUILD_ID" "${BUILD_ID}.${BUILD_NUMBER}"
    else
        get_metadata "${device_array[i]}" "$BUILD_TARGET"
        source compile_os.sh "${device_array[i]}" "$BUILD_ID" "$MANIFEST_FROM_METADATA"
    fi

    source package_os.sh "${device_array[i]}"
    
done

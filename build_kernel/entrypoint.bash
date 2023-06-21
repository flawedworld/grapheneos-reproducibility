#!/bin/bash

set -o errexit -o pipefail

# Set default values 
DEVICES_TO_BUILD="${DEVICES_TO_BUILD:-"raven"}"
MANIFESTS_FOR_BUILD="${MANIFESTS_FOR_BUILD:-"TQ3A.230605.012.2023061402"}"
NPROC_SYNC="${NPROC_SYNC:-8}"
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
    IFS=" " read -r -a manifest_array <<< "$MANIFESTS_FOR_BUILD"

    # This implies either build method one or three.
    if [[ ${#device_array[@]} != ${#manifest_array[@]} ]]; then
        echo "Cannot run: there must be an equal amount of devices to manifests."
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

check_breaking_env

for ((i = 0; i < ${#device_array[@]}; i++)); do
    source build_kernel.sh "${device_array[i]}" "${manifest_array[i]}"
done

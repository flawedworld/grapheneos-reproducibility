#!/bin/bash

DEVICE=$1
CHANNEL=$2

CURRENT_METADATA_FILE="/opt/grapheneos-update-metadata-${DEVICE}-${CHANNEL}"
URL="https://releases.grapheneos.org/${DEVICE}-${CHANNEL}"

if [ -f "$CURRENT_METADATA_FILE" ]; then
    read -r CURRENT_METADATA_NUMBER CURRENT_METADATA_DATETIME CURRENT_METADATA_ID < $CURRENT_METADATA_FILE
fi

read -r BUILD_NUMBER BUILD_DATETIME BUILD_ID BRANCH < <(echo $(curl -s $URL))

if [ -z "$CURRENT_METADATA_NUMBER" ] || [ "$BUILD_DATETIME" != "$CURRENT_METADATA_DATETIME" ]; then
    # docker run --privileged 
    echo "New version, updating..."
elif [ "$BUILD_DATETIME" = "$CURRENT_METADATA_DATETIME" ]; then
    echo "Same version, skipping..."
else
    echo "Something has gone seriously wrong. Hopefully the next one will correct it."
fi

echo "$BUILD_NUMBER" "$BUILD_DATETIME" "$BUILD_ID" "$BRANCH" > "$CURRENT_METADATA_FILE"

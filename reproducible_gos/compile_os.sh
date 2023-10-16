#!/bin/bash

DEVICE=$1
BUILD_NUMBER=$2
BUILD_DATETIME=$3

echo "Device we are building for: $DEVICE"
echo "BUILD_DATETIME is set to: $BUILD_DATETIME"
echo "BUILD_NUMBER is set to: $BUILD_NUMBER"
echo "Using Prebuilt Kernel: $USE_PREBUILT_KERNEL"
echo "Using Prebuilt Applications: $USE_PREBUILT_APPS"
echo "Using Prebuilt Vanadium: $USE_PREBUILT_VANADIUM"
echo "NPROC Sync Count: $NPROC_SYNC"
echo "NPROC Build Count: $NPROC_BUILD"

echo "If any of these settings are blank, stop the build and make an issue or the build WILL fail."

sleep 10

echo "[INFO] Downloading and verifying manifest"
mkdir -p /opt/build/grapheneos/
cd /opt/build/grapheneos/

repo init -u https://github.com/GrapheneOS/platform_manifest.git -b refs/tags/$BUILD_NUMBER
mkdir -p ~/.ssh && curl https://grapheneos.org/allowed_signers > ~/.ssh/grapheneos_allowed_signers
(cd .repo/manifests && git config gpg.ssh.allowedSignersFile ~/.ssh/grapheneos_allowed_signers && git verify-tag "$(git describe)")

echo "[INFO] Syncing GrapheneOS tree"
repo sync -j${NPROC_SYNC} --force-sync --no-clone-bundle --no-tags

echo "[INFO] Setting up adevtool"
yarn install --cwd vendor/adevtool/
source script/envsetup.sh
m aapt2

echo "[INFO] Obtaining proprietary files with adevtool"
adevtool generate-all -d $DEVICE

if [[ $USE_PREBUILT_KERNEL == "false" ]]; then
    echo "[INFO] Building Kernel for ${DEVICE} with tag ${BUILD_NUMBER}"
    source build_kernel.sh $DEVICE $BUILD_NUMBER
fi 

if [[ $USE_PREBUILT_APPS == "false" ]]; then
    export BUILD_AUDITOR=yes
    export BUILD_APPS=yes 
    export BUILD_CAMERA=yes 
    export BUILD_PDFVIEWER=yes
    export BUILD_TALKBACK=yes
    export BUILD_GMSCOMPAT=yes

    echo "[INFO] Installing Android SDK Manager"
    source install_sdk.sh
    echo "[INFO] Building applications for ${DEVICE}"
    source build_applications.sh
fi

if [[ $USE_PREBUILT_VANADIUM == "false" ]]; then
    echo "[INFO] Building Vanadium"
    source build_vanadium.sh $MANIFEST
fi

echo "[INFO] Building OS"
source script/envsetup.sh
# We are not going to support eng or userdebug builds.
choosecombo release $DEVICE user
# At this point, the environment variables BUILD_DATETIME and BUILD_NUMBER are pulled when OFFICIAL_BUILD is true.
if [ "$DEVICE" = "oriole" || "$DEVICE" = "raven" || "$DEVICE" = "bluejay" ]; then
    m vendorbootimage target-files-package otatools-package -j${NPROC_BUILD}
elif [ "$DEVICE" = "panther" || "$DEVICE" = "cheetah" || "$DEVICE" = "lynx" || "$DEVICE" = "tangorpro" ]; then
    m vendorbootimage vendorkernelbootimage target-files-package otatools-package -j${NPROC_BUILD}
else
    m target-files-package otatools-package -j${NPROC_BUILD}
fi
echo "[INFO] OS built"

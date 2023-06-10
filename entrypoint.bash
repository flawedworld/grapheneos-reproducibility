#!/bin/bash

set -o errexit -o pipefail

sudo chown builduser:builduser /opt/build/

export DEVICE=bluejay
export BUILD_ID=TQ2A.230505.002
export OFFICIAL_BUILD=true
export BUILD_DATETIME=1686159583
export BUILD_NUMBER=2023060700

echo "[INFO] Downloading and verifying manifest"
mkdir grapheneos && cd grapheneos
repo init -u https://github.com/GrapheneOS/platform_manifest.git -b refs/tags/TQ2A.230505.002.2023060700
mkdir ~/.ssh && curl https://grapheneos.org/allowed_signers > ~/.ssh/grapheneos_allowed_signers
cd .repo/manifests
git config gpg.ssh.allowedSignersFile ~/.ssh/grapheneos_allowed_signers
git verify-tag $(git describe)
cd /opt/build/grapheneos

echo "[INFO] Syncing GrapheneOS tree"
repo sync -j16

echo "[INFO] Setting up adevtool"
yarn install --cwd vendor/adevtool/
source script/envsetup.sh
m aapt2

echo "[INFO] Obtaining proprietary files with adevtool"
vendor/adevtool/bin/run download vendor/adevtool/dl/ -d $DEVICE -b $BUILD_ID -t factory ota
sudo rm -rf  vendor/adevtool/dl/unpacked/$DEVICE-${BUILD_ID,,}/
sudo vendor/adevtool/scripts/unpack-images.sh vendor/adevtool/dl/$DEVICE-${BUILD_ID,,}-*.zip
sudo vendor/adevtool/bin/run generate-all vendor/adevtool/config/$DEVICE.yml -c vendor/state/$DEVICE.json -s vendor/adevtool/dl/unpacked/$DEVICE-${BUILD_ID,,}/
sudo chown -R builduser:builduser vendor/{google_devices,adevtool}
vendor/adevtool/bin/run ota-firmware vendor/adevtool/config/$DEVICE.yml -f vendor/adevtool/dl/$DEVICE-ota-${BUILD_ID,,}-*.zip

echo "[INFO] Building OS"
source script/envsetup.sh
choosecombo release $DEVICE user
m vendorbootimage target-files-package otatools-package
echo "[INFO] OS built"

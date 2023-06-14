#!/bin/bash

DEVICES=(coral sunfish bramble redfin barbet oriole raven bluejay panther cheetah lynx)

mkdir -p external/avb

git clone https://github.com/GrapheneOS/platform_development.git development
git clone https://android.googlesource.com/platform/external/avb external/avb

for DEVICE in "${DEVICES[@]}"; do
    mkdir -p keys/$DEVICE
    cd keys/$DEVICE
    CN=$1
    ../../development/tools/make_key releasekey "/CN=$CN/"
    ../../development/tools/make_key platform "/CN=$CN/"
    ../../development/tools/make_key shared "/CN=$CN/"
    ../../development/tools/make_key media "/CN=$CN/"
    ../../development/tools/make_key networkstack "/CN=$CN/"
    ../../development/tools/make_key sdk_sandbox "/CN=$CN/"
    ../../development/tools/make_key bluetooth "/CN=$CN/"
    openssl genrsa 4096 | openssl pkcs8 -topk8 -scrypt -out avb.pem
    ../../external/avb/avbtool.py extract_public_key --key avb.pem --output avb_pkmd.bin
    signify -G -n -p factory.pub -s factory.sec
    cd ../..
done

echo completed

#!/bin/bash

DEVICE=$1

# https://github.com/GrapheneOS/platform_development.git 
# Currently, the plan is to include your own made keys. This is here just in case we decide to do this on the fly which will definitely not be recommended at all.
# Packaging also signs the OS as well. 

if [[ $USE_AOSP_TEST_KEYS == "true" ]]; then
    mkdir -p keys/$DEVICE
    ln -s keys/$DEVICE/releasekey.pk8 build/target/product/security/testkey.pk8
    ln -s keys/$DEVICE/platform.pk8 build/target/product/security/platform.pk8
    ln -s keys/$DEVICE/shared.pk8 build/target/product/security/shared.pk8
    ln -s keys/$DEVICE/media.pk8 build/target/product/security/media.pk8
    ln -s keys/$DEVICE/bluetooth.pk8 build/target/product/security/bluetooth.pk8
    ln -s keys/$DEVICE/sdk_sandbox.pk8 build/target/product/security/sdk_sandbox.pk8
    ln -s keys/$DEVICE/networkstack.pk8 build/target/product/security/networkstack.pk8

    ln -s keys/$DEVICE/releasekey.x509.pem build/target/product/security/testkey.x509.pem
    ln -s keys/$DEVICE/platform.x509.pem build/target/product/security/platform.x509.pem
    ln -s keys/$DEVICE/shared.x509.pem build/target/product/security/shared.x509.pem
    ln -s keys/$DEVICE/media.x509.pem build/target/product/security/media.x509.pem
    ln -s keys/$DEVICE/bluetooth.x509.pem build/target/product/security/bluetooth.x509.pem
    ln -s keys/$DEVICE/sdk_sandbox.x509.pem build/target/product/security/sdk_sandbox.x509.pem
    ln -s keys/$DEVICE/networkstack.x509.pem build/target/product/security/networkstack.x509.pem

    ln -s keys/$DEVICE/avb.pem external/avb/test/data/testkey_rsa4096_pub.pem
    ln -s keys/$DEVICE/avb_pkmd.bin external/avb/test/data/testkey_rsa4096_pub.bin

    signify -G -n -p keys/$DEVICE/factory.pub -s keys/$DEVICE/factory.sec
fi

script/release.sh $DEVICE
rsync -av /opt/build/grapheneos/out/release-$DEVICE-$BUILD_NUMBER /opt/build/compiled_os

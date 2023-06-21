#!/bin/bash

DEVICE=$1
MANIFEST=$2

case $DEVICE in
    coral|sunfish)
        mkdir -p /opt/build/kernel/"${DEVICE}" /opt/build/compiled_kernel/"${DEVICE}"
        cd /opt/build/kernel/"${DEVICE}"
        repo init -u https://github.com/GrapheneOS/kernel_manifest-coral.git -b refs/tags/"${MANIFEST}"
        repo sync -j${NPROC_SYNC} --force-sync --no-clone-bundle --no-tags

        if [[ $DEVICE == "coral" ]]; then
            KBUILD_BUILD_VERSION=1 KBUILD_BUILD_USER=build-user KBUILD_BUILD_HOST=build-host KBUILD_BUILD_TIMESTAMP="Thu 01 Jan 1970 12:00:00 AM UTC" BUILD_CONFIG=private/msm-google/build.config.floral build/build.sh
            rsync -av --delete out/android-msm-pixel-4.14/dist/ /opt/build/compiled_kernel/"${DEVICE}"
        else
            KBUILD_BUILD_VERSION=1 KBUILD_BUILD_USER=build-user KBUILD_BUILD_HOST=build-host KBUILD_BUILD_TIMESTAMP="Thu 01 Jan 1970 12:00:00 AM UTC" BUILD_CONFIG=private/msm-google/build.config.sunfish build/build.sh
            rsync -av --delete out/android-msm-pixel-4.14/dist/ /opt/build/compiled_kernel/"${DEVICE}"
        fi
        ;;
    bramble|redfin|barbet)
        mkdir -p /opt/build/kernel/"${DEVICE}" /opt/build/compiled_kernel/"${DEVICE}"
        cd /opt/build/kernel/"${DEVICE}"
        repo init -u https://github.com/GrapheneOS/kernel_manifest-redbull.git -b refs/tags/"${MANIFEST}"
        repo sync -j${NPROC_SYNC} --force-sync --no-clone-bundle --no-tags
        BUILD_CONFIG=private/msm-google/build.config.redbull.vintf build/build.sh
        rsync -av --delete out/android-msm-pixel-4.19/dist/ /opt/build/compiled_kernel/"${DEVICE}"
        ;;
    oriole|raven)
        mkdir -p /opt/build/kernel/"${DEVICE}" /opt/build/compiled_kernel/"${DEVICE}"
        cd /opt/build/kernel/"${DEVICE}"
        repo init -u https://github.com/GrapheneOS/kernel_manifest-raviole.git -b refs/tags/"${MANIFEST}"
        repo sync -j${NPROC_SYNC} --force-sync --no-clone-bundle --no-tags
        LTO=full BUILD_AOSP_KERNEL=1 ./build_slider.sh
        rsync -av --delete out/mixed/dist/ /opt/build/compiled_kernel/"${DEVICE}"
        ;;
    bluejay)
        mkdir -p /opt/build/kernel/"${DEVICE}" /opt/build/compiled_kernel/"${DEVICE}"
        cd /opt/build/kernel/"${DEVICE}"
        repo init -u https://github.com/GrapheneOS/kernel_manifest-bluejay.git -b refs/tags/"${MANIFEST}"
        repo sync -j${NPROC_SYNC} --force-sync --no-clone-bundle --no-tags
        LTO=full BUILD_AOSP_KERNEL=1 ./build_bluejay.sh
        rsync -av --delete out/mixed/dist/ /opt/build/compiled_kernel/"${DEVICE}"
        ;;
    panther|cheetah)
        mkdir -p /opt/build/kernel/"${DEVICE}" /opt/build/compiled_kernel/"${DEVICE}"
        cd /opt/build/kernel/"${DEVICE}"
        repo init -u https://github.com/GrapheneOS/kernel_manifest-pantah.git -b refs/tags/"${MANIFEST}"
        repo sync -j${NPROC_SYNC} --force-sync --no-clone-bundle --no-tags
        LTO=full BUILD_AOSP_KERNEL=1 ./build_cloudripper.sh
        rsync -av --delete out/mixed/dist/ /opt/build/compiled_kernel/"${DEVICE}"
        ;;
    lynx)
        mkdir -p /opt/build/kernel/"${DEVICE}" /opt/build/compiled_kernel/"${DEVICE}"
        cd /opt/build/kernel/"${DEVICE}"
        repo init -u https://github.com/GrapheneOS/kernel_manifest-lynx.git -b refs/tags/"${MANIFEST}"
        repo sync -j${NPROC_SYNC} --force-sync --no-clone-bundle --no-tags
        LTO=full BUILD_AOSP_KERNEL=1 ./build_lynx.sh
        rsync -av --delete out/mixed/dist/ /opt/build/compiled_kernel/"${DEVICE}"
        ;;
    tangorpro)
        mkdir -p /opt/build/kernel/"${DEVICE}" /opt/build/compiled_kernel/"${DEVICE}"
        cd /opt/build/kernel/"${DEVICE}"
        repo init -u https://github.com/GrapheneOS/kernel_manifest-tangorpro.git -b 13
        repo sync -j${NPROC_SYNC} --force-sync --no-clone-bundle --no-tags
        LTO=full BUILD_AOSP_KERNEL=1 ./build_tangorpro.sh
        rsync -av --delete out/mixed/dist/ /opt/build/compiled_kernel/"${DEVICE}"
        ;;
esac

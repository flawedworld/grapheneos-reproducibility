#!/usr/bin/env bash

DEVICE=$1
MANIFEST=refs/tags/$2

make_kernel_directory() {
    local DEVICE="$1"
    mkdir -p /opt/build/kernel/"${DEVICE}"
    cd /opt/build/kernel/"${DEVICE}"
}

case $DEVICE in
    coral|sunfish)
        make_kernel_directory "${DEVICE}"

        repo init -u https://github.com/GrapheneOS/kernel_manifest-coral.git -b "${MANIFEST}"
        repo sync -j${NPROC_SYNC} --force-sync --no-clone-bundle --no-tags

        if [[ $DEVICE == "coral" ]]; then
            KBUILD_BUILD_VERSION=1 KBUILD_BUILD_USER=build-user KBUILD_BUILD_HOST=build-host KBUILD_BUILD_TIMESTAMP="Thu 01 Jan 1970 12:00:00 AM UTC" BUILD_CONFIG=private/msm-google/build.config.floral build/build.sh
            rsync -av --delete out/android-msm-pixel-4.14/dist/ /opt/build/grapheneos/device/google/coral-kernel/
        else
            KBUILD_BUILD_VERSION=1 KBUILD_BUILD_USER=build-user KBUILD_BUILD_HOST=build-host KBUILD_BUILD_TIMESTAMP="Thu 01 Jan 1970 12:00:00 AM UTC" BUILD_CONFIG=private/msm-google/build.config.sunfish build/build.sh
            rsync -av --delete out/android-msm-pixel-4.14/dist/ /opt/build/grapheneos/device/google/sunfish-kernel/
        fi
    ;;
    bramble|redfin|barbet)
        make_kernel_directory "${DEVICE}"

        repo init -u https://github.com/GrapheneOS/kernel_manifest-redbull.git -b "${MANIFEST}"
        repo sync -j${NPROC_SYNC} --force-sync --no-clone-bundle --no-tags

        BUILD_CONFIG=private/msm-google/build.config.redbull.vintf build/build.sh
        rsync -av --delete out/android-msm-pixel-4.19/dist/ /opt/build/grapheneos/device/google/redbull-kernel/vintf/
    ;;
    oriole|raven)
        make_kernel_directory "${DEVICE}"

        repo init -u https://github.com/GrapheneOS/kernel_manifest-raviole.git -b "${MANIFEST}"
        repo sync -j${NPROC_SYNC} --force-sync --no-clone-bundle --no-tags

        LTO=full BUILD_AOSP_KERNEL=1 ./build_slider.sh
        rsync -av --delete out/mixed/dist/ /opt/build/grapheneos/device/google/raviole-kernel/
    ;;
    bluejay)
        make_kernel_directory "${DEVICE}"

        repo init -u https://github.com/GrapheneOS/kernel_manifest-bluejay.git -b "${MANIFEST}"
        repo sync -j${NPROC_SYNC} --force-sync --no-clone-bundle --no-tags

        LTO=full BUILD_AOSP_KERNEL=1 ./build_bluejay.sh
        rsync -av --delete out/mixed/dist/ /opt/build/grapheneos/device/google/bluejay-kernel/
    ;;
    panther|cheetah)
        make_kernel_directory "${DEVICE}"

        repo init -u https://github.com/GrapheneOS/kernel_manifest-pantah.git -b "${MANIFEST}"
        repo sync -j${NPROC_SYNC} --force-sync --no-clone-bundle --no-tags

        LTO=full BUILD_AOSP_KERNEL=1 ./build_cloudripper.sh
        rsync -av --delete out/mixed/dist/ /opt/build/grapheneos/device/google/pantah-kernel/
    ;;
    lynx)
        make_kernel_directory "${DEVICE}"

        repo init -u https://github.com/GrapheneOS/kernel_manifest-lynx.git -b "${MANIFEST}"
        repo sync -j${NPROC_SYNC} --force-sync --no-clone-bundle --no-tags

        LTO=full BUILD_AOSP_KERNEL=1 ./build_lynx.sh
        rsync -av --delete out/mixed/dist/ /opt/build/grapheneos/device/google/lynx-kernel/
    ;;
    tangorpro)
        make_kernel_directory "${DEVICE}"

        repo init -u https://github.com/GrapheneOS/kernel_manifest-tangorpro.git -b "${MANIFEST}"
        repo sync -j${NPROC_SYNC} --force-sync --no-clone-bundle --no-tags
        
        LTO=full BUILD_AOSP_KERNEL=1 ./build_tangorpro.sh
        rsync -av --delete out/mixed/dist/ /opt/build/grapheneos/device/google/lynx-kernel/
    ;;
    felix)
        make_kernel_directory "${DEVICE}"

        repo init -u https://github.com/GrapheneOS/kernel_manifest-felix.git -b "${MANIFEST}"
        repo sync -j${NPROC_SYNC} --force-sync --no-clone-bundle --no-tags

        LTO=full BUILD_AOSP_KERNEL=1 ./build_felix.sh
        rsync -av --delete out/mixed/dist/ /opt/build/grapheneos/device/google/tangorpro-kernel/
    ;;
esac

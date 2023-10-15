#!/usr/bin/env bash

make_kernel_directory() {
    local device="$1"
    mkdir -p /opt/build/kernel/"${device}" /opt/build/compiled_kernel/"${device}"
    cd /opt/build/kernel/"${device}"
}

build_kernel() {
    local DEVICE="$1"
    local MANIFEST="$2"

    if [[ MANIFEST == "latest" ]]; then
        MANIFEST=14
    else
        MANIFEST=refs/tags/"${MANIFEST}"
    fi

    case $DEVICE in
        coral|sunfish)
            make_kernel_directory "${DEVICE}"

            repo init -u https://github.com/GrapheneOS/kernel_manifest-coral.git -b "${MANIFEST}"
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
            make_kernel_directory "${DEVICE}"

            repo init -u https://github.com/GrapheneOS/kernel_manifest-redbull.git -b "${MANIFEST}"
            repo sync -j${NPROC_SYNC} --force-sync --no-clone-bundle --no-tags

            BUILD_CONFIG=private/msm-google/build.config.redbull.vintf build/build.sh
            rsync -av --delete out/android-msm-pixel-4.19/dist/ /opt/build/compiled_kernel/"${DEVICE}"
        ;;
        oriole|raven)
            make_kernel_directory "${DEVICE}"

            repo init -u https://github.com/GrapheneOS/kernel_manifest-raviole.git -b "${MANIFEST}"
            repo sync -j${NPROC_SYNC} --force-sync --no-clone-bundle --no-tags

            LTO=full BUILD_AOSP_KERNEL=1 ./build_slider.sh
            rsync -av --delete out/mixed/dist/ /opt/build/compiled_kernel/"${DEVICE}"
        ;;
        bluejay)
            make_kernel_directory "${DEVICE}"

            repo init -u https://github.com/GrapheneOS/kernel_manifest-bluejay.git -b "${MANIFEST}"
            repo sync -j${NPROC_SYNC} --force-sync --no-clone-bundle --no-tags

            LTO=full BUILD_AOSP_KERNEL=1 ./build_bluejay.sh
            rsync -av --delete out/mixed/dist/ /opt/build/compiled_kernel/"${DEVICE}"
        ;;
        panther|cheetah)
            make_kernel_directory "${DEVICE}"

            repo init -u https://github.com/GrapheneOS/kernel_manifest-pantah.git -b "${MANIFEST}"
            repo sync -j${NPROC_SYNC} --force-sync --no-clone-bundle --no-tags

            LTO=full BUILD_AOSP_KERNEL=1 ./build_cloudripper.sh
            rsync -av --delete out/mixed/dist/ /opt/build/compiled_kernel/"${DEVICE}"
        ;;
        lynx)
            make_kernel_directory "${DEVICE}"

            repo init -u https://github.com/GrapheneOS/kernel_manifest-lynx.git -b "${MANIFEST}"
            repo sync -j${NPROC_SYNC} --force-sync --no-clone-bundle --no-tags

            LTO=full BUILD_AOSP_KERNEL=1 ./build_lynx.sh
            rsync -av --delete out/mixed/dist/ /opt/build/compiled_kernel/"${DEVICE}"
        ;;
        tangorpro)
            make_kernel_directory "${DEVICE}"

            repo init -u https://github.com/GrapheneOS/kernel_manifest-tangorpro.git -b "${MANIFEST}"
            repo sync -j${NPROC_SYNC} --force-sync --no-clone-bundle --no-tags
            
            LTO=full BUILD_AOSP_KERNEL=1 ./build_tangorpro.sh
            rsync -av --delete out/mixed/dist/ /opt/build/compiled_kernel/"${DEVICE}"
        ;;
        felix)
            make_kernel_directory "${DEVICE}"

            repo init -u https://github.com/GrapheneOS/kernel_manifest-felix.git -b "${MANIFEST}"
            repo sync -j${NPROC_SYNC} --force-sync --no-clone-bundle --no-tags

            LTO=full BUILD_AOSP_KERNEL=1 ./build_felix.sh
            rsync -av --delete out/mixed/dist/ /opt/build/compiled_kernel/"${DEVICE}"
        ;;
    esac
}

if [[ $BUILD_CORAL == "yes" ]]; then
    build_kernel "coral" "${CORAL_MANIFEST}"
fi

if [[ $BUILD_SUNFISH == "yes" ]]; then
    build_kernel "sunfish" "${SUNFISH_MANIFEST}"
fi

if [[ $BUILD_BRAMBLE == "yes" ]]; then
    build_kernel "bramble" "${BRAMBLE_MANIFEST}"
fi

if [[ $BUILD_REDFIN == "yes" ]]; then
    build_kernel "redfin" "${REDFIN_MANIFEST}"
fi

if [[ $BUILD_BARBET == "yes" ]]; then
    build_kernel "barbet" "${BARBET_MANIFEST}"
fi

if [[ $BUILD_ORIOLE == "yes" ]]; then
    build_kernel "oriole" "${ORIOLE_MANIFEST}"
fi

if [[ $BUILD_RAVEN == "yes" ]]; then
    build_kernel "raven" "${RAVEN_MANIFEST}"
fi

if [[ $BUILD_BLUEJAY == "yes" ]]; then
    build_kernel "bluejay" "${BLUEJAY_MANIFEST}"
fi

if [[ $BUILD_PANTHER == "yes" ]]; then
    build_kernel "panther" "${PANTHER_MANIFEST}"
fi

if [[ $BUILD_CHEETAH == "yes" ]]; then
    build_kernel "cheetah" "${CHEETAH_MANIFEST}"
fi

if [[ $BUILD_LYNX == "yes" ]]; then
    build_kernel "lynx" "${LYNX_MANIFEST}"
fi

if [[ $BUILD_TANGORPRO == "yes" ]]; then
    build_kernel "tangorpro" "${TANGORPRO_MANIFEST}"
fi

if [[ $BUILD_FELIX == "yes" ]]; then
    build_kernel "felix" "${FELIX_MANIFEST}"
fi

#!/bin/bash

set -o errexit -o pipefail

# Set default values 
DEVICES_TO_BUILD="raven"
MANIFESTS_FOR_BUILD="${MANIFESTS_FOR_BUILD:-""}"
BUILD_TARGET="${BUILD_TARGET:-"stable"}"
BUILD_NUMBER="${BUILD_NUMBER:-""}"
BUILD_DATETIME="${BUILD_DATETIME:-""}"
BUILD_ID="${BUILD_ID:-""}"
USE_PREBUILT_KERNEL="${USE_PREBUILT_KERNEL:-false}"
USE_PREBUILT_APPS="${USE_PREBUILT_APPS:-false}"
PACKAGE_OS="${PACKAGE_OS:-true}"
APPS_TO_BUILD="${APPS_TO_BUILD:-all}"
USE_GRAPHENEOS_TEST_KEYS="${USE_GRAPHENEOS_TEST_KEYS:-false}"
OFFICIAL_BUILD="${OFFICIAL_BUILD:-true}"
NPROC_SYNC="${NPROC_SYNC:-8}"
NPROC_BUILD="${NPROC_BUILD:-8}"
SKIP_GRAPHENEOS="${SKIP_GRAPHENEOS:-false}"
BUILD_VANADIUM="${BUILD_VANADIUM:-false}"
GIT_USERNAME="${GIT_USERNAME:-grapheneos}"
GIT_EMAILADDRESS="${GIT_EMAILADDRESS:-grapheneos-build@localhost}"

# Set ownership of the target directory
sudo chown builduser:builduser /opt/build/grapheneos/

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
        # If this isn't build method one...
        if [[ -z $BUILD_TARGET ]]; then
            # If this isn't build method three...
            if [[ -z $BUILD_NUMBER || -z $BUILD_DATETIME || -z $BUILD_ID ]]; then
                echo "Cannot run: there must be an equal amount of devices to manifests unless you specify BUILD_TARGET=stable or BUILD_TARGET=development OR you specify BUILD_NUMBER and BUILD_DATETIME and BUILD_ID."
                exit 1
            fi
        else
            # If this is a combination of build method one or three...
            if [[ ! -z $BUILD_NUMBER || ! -z $BUILD_DATETIME || ! -z $BUILD_ID ]]; then
                echo "You have specified a BUILD_NUMBER, BUILD_DATETIME, and BUILD_ID as well as a BUILD_TARGET. BUILD_TARGET is for one-off builds of the latest builds and development builds directly from git."
                exit 1
            fi
        fi
    # If the BUILD_TARGET exists and is not an acceptable value...
    elif [[ $BUILD_TARGET != "stable" && $BUILD_TARGET != "development" && $BUILD_TARGET != "beta" && $BUILD_TARGET != "alpha" && $BUILD_TARGET != "testing" && ! -z $BUILD_TARGET ]]; then
        echo "BUILD_TARGET can currently only be set to stable, beta, alpha, and development."
        exit 1
    # TODO: flesh out
    elif [[ $SKIP_GRAPHENEOS == "true" ]]; then
        echo "Currently unsupported."
        exit 1
    # If we are going for a reproducible build...
    elif [[ $OFFICIAL_BUILD == "true" ]]; then
        # If a local_manifest directory exists...
        if [[ -d ".repo/local_manifests" ]]; then
            echo "Official builds do not use custom manifests. Please remove your bind mount and retry."
            exit 1
        fi

        # If build method two was detected... 
        if [[ ! -z $MANIFESTS_FOR_BUILD ]]; then
            echo "Official builds imply reproducibility. This method of building is not compatible."
            exit 1
        fi
    # If we want a final ZIP and if we don't find the keys folder and we aren't using the test keys...
    elif [[ $PACKAGE_OS == "true" && ! -d "/opt/build/grapheneos/keys" && $USE_GRAPHENEOS_TEST_KEYS == "false" ]]; then
        echo "Packaging the OS requires signed keys to be available. Check your bind mount and retry or use GrapheneOS test keys (not recommended)."
        exit 1
    fi
}

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

compile_os () {
    local DEVICE=$1
    local BUILD_ID=$2
    local MANIFEST=$3

    echo "Device we are building for: $DEVICE"
    echo "Stock Build ID associated with the device: $BUILD_ID"
    echo "Manifest from GrapheneOS to build from: $MANIFEST"
    echo
    echo "OFFICIAL_BUILD status: $OFFICIAL_BUILD"
    if [ "$OFFICIAL_BUILD" = "true" ]; then
        echo "BUILD_DATETIME is set to: $BUILD_DATETIME"
        echo "BUILD_NUMBER is set to: $BUILD_NUMBER"
        echo "BUILD_ID is set to: $BUILD_ID"
    fi
    echo "Are we using the GrapheneOS Test Keys: $USE_GRAPHENEOS_TEST_KEYS"
    echo
    echo "Are we using the prebuilt kernel: $USE_PREBUILT_KERNEL"
    echo "Are we using the prebuilt applications: $USE_PREBUILT_APPS"
    if [ "$APPS_TO_BUILD" != "all" ]; then
        IFS=" " read -r -a apps_array <<< "$APPS_TO_BUILD"
        echo "We are building the following apps: $apps_array"
    fi
    echo "Are we building Vanadium: $BUILD_VANADIUM"
    echo
    echo "NPROC Sync Count: $NPROC_SYNC"
    echo "NPROC Build Count: $NPROC_BUILD"

    echo "If any of these settings are blank, stop the build and make an issue or the build WILL fail."

    sleep 10

    echo "[INFO] Downloading and verifying manifest"
    if [ "$MANIFEST" = "development" ]; then
        case $DEVICE in
            oriole|raven|bluejay|panther|cheetah|lynx)
                repo init -u https://github.com/GrapheneOS/platform_manifest.git -b 13
                ;;
            *)
                repo init -u https://github.com/GrapheneOS/platform_manifest.git -b 13-coral
                ;;
        esac
    else
        repo init -u https://github.com/GrapheneOS/platform_manifest.git -b refs/tags/$MANIFEST
        mkdir -p ~/.ssh && curl https://grapheneos.org/allowed_signers > ~/.ssh/grapheneos_allowed_signers
        (cd .repo/manifests && git config gpg.ssh.allowedSignersFile ~/.ssh/grapheneos_allowed_signers && git verify-tag "$(git describe)")
    fi

    echo "[INFO] Syncing GrapheneOS tree"
    repo sync -j${NPROC_SYNC} --force-sync --no-clone-bundle --no-tags

    if [ "$USE_PREBUILT_KERNEL" = "false" ]; then
        echo "[INFO] Building Kernel for ${DEVICE}"
        build_kernel $DEVICE
    fi

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
    # We are not going to support eng or userdebug builds.
    choosecombo release $DEVICE user
    # At this point, the environment variables BUILD_DATETIME and BUILD_NUMBER are pulled when OFFICIAL_BUILD is true.
    if [ "$DEVICE" = "oriole" || "$DEVICE" = "raven" || "$DEVICE" = "bluejay" ]; then
        m vendorbootimage target-files-package otatools-package -j${NPROC_BUILD}
    elif [ "$DEVICE" = "panther" || "$DEVICE" = "cheetah" || "$DEVICE" = "lynx" ]; then
        m vendorbootimage vendorkernelbootimage target-files-package otatools-package -j${NPROC_BUILD}
    else
         m target-files-package otatools-package -j${NPROC_BUILD}
    fi
    echo "[INFO] OS built"
}

build_kernel () {
    DEVICE=$1

    case $DEVICE in
        coral|sunfish)
            mkdir -p android/kernel/coral
            cd android/kernel/coral
            repo init -u https://github.com/GrapheneOS/kernel_manifest-coral.git -b 13
            repo sync -j${NPROC_SYNC}
            if [[ $DEVICE == "coral" ]]; then
                KBUILD_BUILD_VERSION=1 KBUILD_BUILD_USER=build-user KBUILD_BUILD_HOST=build-host KBUILD_BUILD_TIMESTAMP="Thu 01 Jan 1970 12:00:00 AM UTC" BUILD_CONFIG=private/msm-google/build.config.floral build/build.sh
                rsync -av --delete out/android-msm-pixel-4.14/dist/ device/google/coral-kernel/
            else
                KBUILD_BUILD_VERSION=1 KBUILD_BUILD_USER=build-user KBUILD_BUILD_HOST=build-host KBUILD_BUILD_TIMESTAMP="Thu 01 Jan 1970 12:00:00 AM UTC" BUILD_CONFIG=private/msm-google/build.config.sunfish build/build.sh
                rsync -av --delete out/android-msm-pixel-4.14/dist/ device/google/sunfish-kernel/
            fi
            ;;
        bramble|redfin|barbet)
            mkdir -p android/kernel/redbull
            cd android/kernel/redbull
            repo init -u https://github.com/GrapheneOS/kernel_manifest-redbull.git -b 13
            repo sync -j${NPROC_SYNC}
            BUILD_CONFIG=private/msm-google/build.config.redbull.vintf build/build.sh
            rsync -av --delete out/android-msm-pixel-4.19/dist/ device/google/redbull-kernel/vintf/
            ;;
        oriole|raven)
            mkdir -p android/kernel/raviole
            cd android/kernel/raviole
            repo init -u https://github.com/GrapheneOS/kernel_manifest-raviole.git -b 13
            repo sync -j${NPROC_SYNC}
            LTO=full BUILD_AOSP_KERNEL=1 ./build_slider.sh
            rsync -av --delete out/mixed/dist/ device/google/raviole-kernel/
            ;;
        bluejay)
            mkdir -p android/kernel/bluejay
            cd android/kernel/bluejay
            repo init -u https://github.com/GrapheneOS/kernel_manifest-bluejay.git -b 13
            repo sync -j${NPROC_SYNC}
            LTO=full BUILD_AOSP_KERNEL=1 ./build_bluejay.sh
            rsync -av --delete out/mixed/dist/ device/google/bluejay-kernel/
            ;;
        panther|cheetah)
            mkdir -p android/kernel/pantah
            cd android/kernel/pantah
            repo init -u https://github.com/GrapheneOS/kernel_manifest-pantah.git -b 13
            repo sync -j${NPROC_SYNC}
            LTO=full BUILD_AOSP_KERNEL=1 ./build_cloudripper.sh
            rsync -av --delete out/mixed/dist/ device/google/pantah-kernel/
            ;;
        lynx)
            mkdir -p android/kernel/lynx
            cd android/kernel/lynx
            repo init -u https://github.com/GrapheneOS/kernel_manifest-lynx.git -b 13
            repo sync -j${NPROC_SYNC}
            LTO=full BUILD_AOSP_KERNEL=1 ./build_lynx.sh
            rsync -av --delete out/mixed/dist/ device/google/lynx-kernel/
            ;;
    esac
}

package_os () {
    DEVICE=$1
    # https://github.com/GrapheneOS/platform_development.git 
    # Currently, the plan is to include your own made keys. This is here just in case we decide to do this on the fly which will definitely not be recommended at all.
    # Packaging also signs the OS as well. 

    if [[ $USE_AOSP_TEST_KEYS == "true" ]]; then
        mkdir -p keys/$DEVICE
        ln -s keys/$DEVICE/releasekey.pk8 /build/target/product/security/testkey.pk8
        ln -s keys/$DEVICE/platform.pk8 /build/target/product/security/platform.pk8
        ln -s keys/$DEVICE/shared.pk8 /build/target/product/security/shared.pk8
        ln -s keys/$DEVICE/media.pk8 /build/target/product/security/media.pk8
        ln -s keys/$DEVICE/bluetooth.pk8 /build/target/product/security/bluetooth.pk8
        ln -s keys/$DEVICE/sdk_sandbox.pk8 /build/target/product/security/sdk_sandbox.pk8
        ln -s keys/$DEVICE/networkstack.pk8 /build/target/product/security/networkstack.pk8

        ln -s keys/$DEVICE/releasekey.x509.pem /build/target/product/security/testkey.x509.pem
        ln -s keys/$DEVICE/platform.x509.pem /build/target/product/security/platform.x509.pem
        ln -s keys/$DEVICE/shared.x509.pem /build/target/product/security/shared.x509.pem
        ln -s keys/$DEVICE/media.x509.pem /build/target/product/security/media.x509.pem
        ln -s keys/$DEVICE/bluetooth.x509.pem /build/target/product/security/bluetooth.x509.pem
        ln -s keys/$DEVICE/sdk_sandbox.x509.pem /build/target/product/security/sdk_sandbox.x509.pem
        ln -s keys/$DEVICE/networkstack.x509.pem /build/target/product/security/networkstack.x509.pem

        ln -s keys/$DEVICE/avb.pem /external/avb/test/data/testkey_rsa4096_pub.pem
        ln -s keys/$DEVICE/avb_pkmd.bin /external/avb/test/data/testkey_rsa4096_pub.bin

        signify -G -n -p keys/$DEVICE/factory.pub -s keys/$DEVICE/factory.sec
    fi

    script/release.sh $DEVICE
}

# build_vanadium () {
#     git clone https://github.com/GrapheneOS/Vanadium.git
#     cd Vanadium
#     git checkout CORRECT_BRANCH_OR_TAG
# }

build_applications () {
    # Install SDK

    mkdir -p "$HOME/android/sdk/bootstrap"
    cd "$HOME/android/sdk/bootstrap"
    curl -O https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip
    echo 'bd1aa17c7ef10066949c88dc6c9c8d536be27f992a1f3b5a584f9bd2ba5646a0  commandlinetools-linux-9477386_latest.zip' | sha256sum -c
    unzip commandlinetools-linux-9477386_latest.zip
    cmdline-tools/bin/sdkmanager 'cmdline-tools;latest' --sdk_root="$HOME/android/sdk"
    cd ..
    rm -r bootstrap

    export ANDROID_HOME="$HOME/android/sdk"
    export PATH="$HOME/android/sdk/cmdline-tools/latest/bin:$PATH"

    sdkmanager platform-tools

    export PATH="$HOME/android/sdk/platform-tools:$PATH"

    sdkmanager 'build-tools;33.0.2'

    export PATH="$HOME/android/sdk/platform-tools:$PATH"

    sdkmanager ndk-bundle

    export PATH="$HOME/android/sdk/ndk-bundle:$PATH"

    sdkmanager --update

    # Download and build the applications
    if [ "$APPS_TO_BUILD" != "all" ]; then
        IFS=" " read -r -a apps_array <<< "$APPS_TO_BUILD"
        for APP in "${apps_array[@]}"; do
            
            VERSION_CODE=aapt2 dump badging external/"${APP}"/prebuilt/"${APP}".apk | grep -oP "versionCode='\K\d+"
            if [ "$APP" = "GmsCompat" ]; then
                git clone "https://github.com/GrapheneOS/platform_packages_apps_GmsCompat.git"
                cd "platform_packages_apps_GmsCompat"
            else 
                git clone "https://github.com/GrapheneOS/$APP.git"
                cd "$APP"
            fi
            
            # If BUILD_TARGET exists, build newest
            if [[ ! -z "$BUILD_TARGET" ]]; then
                if [ "$APP" = "GmsCompat" ]; then
                    git checkout tags/"$(git describe --tags --abbrev=0)"
                    cd config-holder/
                else
                    git checkout tags/"$(git describe --tags --abbrev=0)"
                fi
            # If MANIFESTS_FOR_BUILD or BUILD_NUMBER exists, grab APK, dump using AAPT2 from , then grab from latest
            elif [[ ! -z "$MANIFESTS_FOR_BUILD" || ! -z "$BUILD_NUMBER" ]]; then
                if [ "$APP" = "GmsCompat" ]; then
                    git checkout tags/"${VERSION_CODE}"
                    cd config-holder/
                else
                    git checkout tags/"${VERSION_CODE}"
                fi
            fi

            # Update Gradle 
            GRADLE_VERSION=$(grep '^distributionUrl=' gradle/wrapper/gradle-wrapper.properties | awk -F'/' '{print $NF}' | cut -d'-' -f2)
            GRADLE_CHECKSUM=$(sed -n 's/^distributionSha256Sum=//p' gradle/wrapper/gradle-wrapper.properties)

            ./gradlew wrapper --gradle-version="$GRADLE_VERSION" --gradle-distribution-sha256-sum="$GRADLE_CHECKSUM"
            ./gradlew wrapper --gradle-version="$GRADLE_VERSION" --gradle-distribution-sha256-sum="$GRADLE_CHECKSUM"

            ./gradlew build

            cd ..
        done
    else
        apps_array=("Auditor" "Apps" "Camera" "PdfViewer" "talkback" "GmsCompat")
        for APP in "${apps_array[@]}"; do
            VERSION_CODE=aapt2 dump badging external/"${APP}"/prebuilt/"${APP}".apk | grep -oP "versionCode='\K\d+"
            if [ "$APP" = "GmsCompat" ]; then
                git clone "https://github.com/GrapheneOS/platform_packages_apps_GmsCompat.git"
                cd "platform_packages_apps_GmsCompat"
            else 
                git clone "https://github.com/GrapheneOS/$APP.git"
                cd "$APP"
            fi
            
            # If BUILD_TARGET exists, build newest
            if [[ ! -z "$BUILD_TARGET" ]]; then
                if [ "$APP" = "GmsCompat" ]; then
                    git checkout tags/"$(git describe --tags --abbrev=0)"
                    cd config-holder/
                else
                    git checkout tags/"$(git describe --tags --abbrev=0)"
                fi
            # If MANIFESTS_FOR_BUILD or BUILD_NUMBER exists, grab APK, dump using AAPT2 from , then grab from latest
            elif [[ ! -z "$MANIFESTS_FOR_BUILD" || ! -z "$BUILD_NUMBER" ]]; then
                if [ "$APP" = "GmsCompat" ]; then
                    git checkout tags/"${VERSION_CODE}"
                    cd config-holder/
                else
                    git checkout tags/"${VERSION_CODE}"
                fi
            fi

            # Update Gradle 
            GRADLE_VERSION=$(grep '^distributionUrl=' gradle/wrapper/gradle-wrapper.properties | awk -F'/' '{print $NF}' | cut -d'-' -f2)
            GRADLE_CHECKSUM=$(sed -n 's/^distributionSha256Sum=//p' gradle/wrapper/gradle-wrapper.properties)

            ./gradlew wrapper --gradle-version="$GRADLE_VERSION" --gradle-distribution-sha256-sum="$GRADLE_CHECKSUM"
            ./gradlew wrapper --gradle-version="$GRADLE_VERSION" --gradle-distribution-sha256-sum="$GRADLE_CHECKSUM"

            ./gradlew build

            cd ..
        done
    fi
}

check_breaking_env

for ((i = 0; i < ${#device_array[@]}; i++)); do

    # This is for the case of "I have a BUILD_NUMBER, BUILD_DATETIME and BUILD_ID and I don't want to check against MANIFESTS_TO_BUILD or a BUILD_TARGET".
    if [[ -z $BUILD_TARGET && -z $MANIFESTS_FOR_BUILD ]]; then
        compile_os "${device_array[i]}" "$BUILD_ID" "${BUILD_ID}.${BUILD_NUMBER}"
    fi

    case $BUILD_TARGET in
        stable|beta|alpha|testing)
            get_metadata "${device_array[i]}" "$BUILD_TARGET"
            compile_os "${device_array[i]}" "$BUILD_ID" "$MANIFEST_FROM_METADATA"
            ;;
        development)
            compile_os "${device_array[i]}" "$BUILD_ID" "development"
            ;;
        *)
            BUILD_ID=$(echo "${manifest_array[i]}" | cut -d'.' -f1-3)
            compile_os "${device_array[i]}" "$BUILD_ID" "${manifest_array[i]}"
            ;;
    esac

    if [ "$PACKAGE_OS" = "true" ]; then
        package_os "${device_array[i]}"
    fi

done

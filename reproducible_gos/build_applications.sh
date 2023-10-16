#!/usr/bin/env bash

make_app_directory() {
    local app="$1"
    mkdir -p /opt/build/apps/
    cd /opt/build/apps/
}

clone_repository() {
    local app_dir="$1"
    local repo_url="https://github.com/GrapheneOS/${app_dir}.git"
    git clone "$repo_url" 
    cd "$app_dir"
}

move_compiled_apps() {
    local app="$1"
    if [[ "${app}" == "GmsCompat" ]]; then
        rsync -av "/opt/build/apps/platform_packages_apps_GmsCompat/config-holder/app/build/outputs/apk/release/app-release-unsigned.apk" "/opt/build/grapheneos/external/${app}Config/prebuilt/${APP}Config.apk"
    elif [[ "${app}" == "TalkBack" ]]; then
        rsync -av "/opt/build/apps/TalkBack/build/outputs/apk/phone/release/TalkBack-phone-release-unsigned.apk" "/opt/build/grapheneos/external/$app/prebuilt/talkback.apk"
    else 
        rsync -av "/opt/build/apps/$app/app/build/outputs/apk/release/app-release-unsigned.apk" "/opt/build/grapheneos/external/$app/prebuilt/$app.apk"
    fi
}

build_app() {
    GRADLE_VERSION=$(awk -F'/' '/^distributionUrl=/ {print $NF}' gradle/wrapper/gradle-wrapper.properties | cut -d'-' -f2)
    GRADLE_CHECKSUM=$(awk -F'=' '/^distributionSha256Sum=/ {print $NF}' gradle/wrapper/gradle-wrapper.properties)

    ./gradlew wrapper --gradle-version="$GRADLE_VERSION" --gradle-distribution-sha256-sum="$GRADLE_CHECKSUM"
    ./gradlew wrapper --gradle-version="$GRADLE_VERSION" --gradle-distribution-sha256-sum="$GRADLE_CHECKSUM"

    ./gradlew build
}

check_app_version() {
    local APP="$1"

    # Use the prebuilt APK's versionCode and checkout the tag related
    if [ "$APP" = "GmsCompat" ]; then
        VERSION_CODE=$(aapt2 dump badging "external/${APP}/prebuilt/${APP}Config.apk" | grep -oP "versionCode='\K\d+")
        git checkout tags/"${VERSION_CODE}"
        cd config-holder/
    else
        VERSION_CODE=$(aapt2 dump badging "external/${APP}/prebuilt/${APP}.apk" | grep -oP "versionCode='\K\d+")
        git checkout tags/"${VERSION_CODE}"
    fi
}

if [[ $BUILD_APPS == "yes" ]]; then
    make_app_directory "Apps"
    clone_repository "Apps"

    check_app_version "Apps"

    build_app "Apps"

    move_compiled_apps "Apps"
fi

if [[ $BUILD_AUDITOR == "yes" ]]; then
    make_app_directory "Auditor"
    clone_repository "Auditor"

    check_app_version "Auditor"

    build_app

    move_compiled_apps "Auditor"
fi

if [[ $BUILD_CAMERA == "yes" ]]; then
    make_app_directory "Camera"
    clone_repository "Camera"

    check_app_version "Camera"

    build_app

    move_compiled_apps "Camera"
fi

if [[ $BUILD_PDFVIEWER == "yes" ]]; then
    make_app_directory "PdfViewer"
    clone_repository "PdfViewer"

    check_app_version "PdfViewer"

    if [[ -f "package.json" ]]; then
        npm install
    else
        git submodule update --init --recursive
    fi

    build_app

    move_compiled_apps "PdfViewer"
fi

if [[ $BUILD_TALKBACK == "yes" ]]; then
    make_app_directory "TalkBack"
    clone_repository "TalkBack"

    check_app_version "TalkBack"

    build_app

    move_compiled_apps "TalkBack"
fi

if [[ $BUILD_GMSCOMPAT == "yes" ]]; then
    make_app_directory "GmsCompat"
    clone_repository "platform_packages_apps_GmsCompat"

    check_app_version "GmsCompat"

    build_app

    move_compiled_apps "GmsCompat"
fi

cd /opt/build/grapheneos

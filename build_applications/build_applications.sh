#!/usr/bin/env bash

make_app_directory() {
    local app="$1"
    mkdir -p /opt/build/apps/ /opt/build/compiled_apps/$app
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
        rsync -av "/opt/build/apps/platform_packages_apps_GmsCompat/config-holder/app/build/outputs/apk/release/app-release-unsigned.apk" "/opt/build/compiled_apps/${app}/${app}Config.apk"
    elif [[ "${app}" == "TalkBack" ]]; then
        rsync -av "/opt/build/apps/TalkBack/build/outputs/apk/phone/release/TalkBack-phone-release-unsigned.apk" "/opt/build/compiled_apps/${app}/talkback.apk"
    else 
        rsync -av "/opt/build/apps/${app}/app/build/outputs/apk/release/app-release-unsigned.apk" "/opt/build/compiled_apps/${app}/${app}.apk"
    fi
}

build_app() {
    GRADLE_VERSION=$(awk -F'/' '/^distributionUrl=/ {print $NF}' gradle/wrapper/gradle-wrapper.properties | cut -d'-' -f2)
    GRADLE_CHECKSUM=$(awk -F'=' '/^distributionSha256Sum=/ {print $NF}' gradle/wrapper/gradle-wrapper.properties)

    ./gradlew wrapper --gradle-version="$GRADLE_VERSION" --gradle-distribution-sha256-sum="$GRADLE_CHECKSUM"
    ./gradlew wrapper --gradle-version="$GRADLE_VERSION" --gradle-distribution-sha256-sum="$GRADLE_CHECKSUM"

    ./gradlew build
}

if [[ $BUILD_APPS == "yes" ]]; then
    make_app_directory "Apps"
    clone_repository "Apps"

    if [[ $APPS_MANIFEST == "latest" ]]; then
        git checkout tags/"$(git describe --tags --abbrev=0)"
    elif [[ $APPS_MANIFEST == "development" ]]; then
        :
    else
        git checkout tags/"${APPS_MANIFEST}"
    fi

    build_app

    move_compiled_apps "Apps"
fi

if [[ $BUILD_AUDITOR == "yes" ]]; then
    make_app_directory "Auditor"
    clone_repository "Auditor"

    if [[ $AUDITOR_MANIFEST == "latest" ]]; then
        git checkout tags/"$(git describe --tags --abbrev=0)"
    elif [[ $AUDITOR_MANIFEST == "development" ]]; then
        :
    else
        git checkout tags/"${AUDITOR_MANIFEST}"
    fi

    build_app

    move_compiled_apps "Auditor"
fi

if [[ $BUILD_CAMERA == "yes" ]]; then
    make_app_directory "Camera"
    clone_repository "Camera"

    if [[ $CAMERA_MANIFEST == "latest" ]]; then
        git checkout tags/"$(git describe --tags --abbrev=0)"
    elif [[ $CAMERA_MANIFEST == "development" ]]; then
        :
    else
        git checkout tags/"${CAMERA_MANIFEST}"
    fi

    build_app

    move_compiled_apps "Camera"
fi

if [[ $BUILD_PDFVIEWER == "yes" ]]; then
    make_app_directory "PdfViewer"
    clone_repository "PdfViewer"

    if [[ $PDFVIEWER_MANIFEST == "latest" ]]; then
        git checkout tags/"$(git describe --tags --abbrev=0)"
    elif [[ $PDFVIEWER_MANIFEST == "development" ]]; then
        :
    else
        git checkout tags/"${PDFVIEWER_MANIFEST}"
    fi

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

    build_app

    move_compiled_apps "TalkBack"
fi

if [[ $BUILD_GMSCOMPAT == "yes" ]]; then
    make_app_directory "GmsCompat"
    clone_repository "platform_packages_apps_GmsCompat"

    if [[ $GMSCOMPAT_MANIFEST == "development" ]]; then
        cd config-holder/
    elif [[ $GMSCOMPAT_MANIFEST == "latest" ]]; then
        git checkout tags/"$(git describe --tags --abbrev=0)"
        cd config-holder/
    else
        git checkout tags/"${GMSCOMPAT_MANIFEST}"
        cd config-holder/
    fi

    build_app

    move_compiled_apps "GmsCompat"
fi

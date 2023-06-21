#!/bin/bash

MANIFEST=$1

# Download and build the applications
if [ "$APPS_TO_BUILD" != "all" ]; then
    IFS=" " read -r -a apps_array <<< "$APPS_TO_BUILD"
else
    apps_array=("Auditor" "Apps" "Camera" "PdfViewer" "TalkBack" "GmsCompat")
fi

for APP in "${apps_array[@]}"; do
    APP=${APP//\"/}
    mkdir -p /opt/build/apps/ /opt/build/compiled_apps/$APP
    cd /opt/build/apps/

    clone_repository() {
        local app_dir="$1"
        local repo_url="https://github.com/GrapheneOS/${app_dir}.git"
        git clone "$repo_url" 
        cd "$app_dir"
    }

    if [ "$APP" = "GmsCompat" ]; then
        clone_repository "platform_packages_apps_GmsCompat" 
    else
        clone_repository "$APP"
    fi

    # If MANIFEST is development, build newest straight from Github
    if [[ $MANIFEST == "development" ]]; then
        if [ "$APP" = "GmsCompat" ]; then
            cd config-holder/
        fi
    # If MANIFEST is latest, build the latest tag
    elif [[ $MANIFEST == "latest" ]]; then
        if [ "$APP" = "GmsCompat" ]; then
            git checkout tags/"$(git describe --tags --abbrev=0)"
            cd config-holder/
        elif [[ "$APP" != "TalkBack" ]]; then
            git checkout tags/"$(git describe --tags --abbrev=0)"
        fi
    fi

    if [[ $APP == "PdfViewer" && -f "package.json" ]]; then
        npm install
    else
        git submodule update --init --recursive
    fi

    GRADLE_VERSION=$(awk -F'/' '/^distributionUrl=/ {print $NF}' gradle/wrapper/gradle-wrapper.properties | cut -d'-' -f2)
    GRADLE_CHECKSUM=$(awk -F'=' '/^distributionSha256Sum=/ {print $NF}' gradle/wrapper/gradle-wrapper.properties)

    ./gradlew wrapper --gradle-version="$GRADLE_VERSION" --gradle-distribution-sha256-sum="$GRADLE_CHECKSUM"
    ./gradlew wrapper --gradle-version="$GRADLE_VERSION" --gradle-distribution-sha256-sum="$GRADLE_CHECKSUM"

    ./gradlew build

    if [[ $APP == "GmsCompat" ]]; then
        rsync -av "/opt/build/apps/platform_packages_apps_GmsCompat/config-holder/app/build/outputs/apk/release/app-release-unsigned.apk" "/opt/build/compiled_apps/$APP/${APP}Config.apk"
    elif [[ $APP == "TalkBack" ]]; then
        rsync -av "/opt/build/apps/TalkBack/build/outputs/apk/phone/release/TalkBack-phone-release-unsigned.apk" "/opt/build/compiled_apps/$APP/talkback.apk"
    else 
        rsync -av "/opt/build/apps/$APP/app/build/outputs/apk/release/app-release-unsigned.apk" "/opt/build/compiled_apps/$APP/$APP.apk"
    fi
done

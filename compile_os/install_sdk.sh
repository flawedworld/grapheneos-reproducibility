#!/bin/bash

mkdir -p "$HOME/android/sdk/bootstrap" "$HOME/android/sdk/licenses"
cd "$HOME/android/sdk/bootstrap"
curl -O https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip
echo 'bd1aa17c7ef10066949c88dc6c9c8d536be27f992a1f3b5a584f9bd2ba5646a0  commandlinetools-linux-9477386_latest.zip' | sha256sum -c
unzip commandlinetools-linux-9477386_latest.zip
# Get past annoying license prompt
echo "24333f8a63b6825ea9c5514f83c2829b004d1fee" > "$HOME/android/sdk/licenses/android-sdk-license"
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

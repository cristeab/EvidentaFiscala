#!/bin/bash

# $HOME/Qt/$QT_VER/macos/bin/lupdate qml src -ts langs/fr.ts

set -e # exit immeditalley on error

QT_VER=6.11.0
APP_NAME=FiscalRecords
MAJOR_VERSION=1.2
MINOR_VERSION=$(git rev-list --count HEAD)
APP_VERSION="${MAJOR_VERSION}.${MINOR_VERSION}"

DEVELOPER_ID="Bogdan Cristea"
DEVELOPER_USERNAME="cristeab@gmail.com"
TEAM_ID="FAARUB626Q"
PKG_NAME=${APP_NAME}-${APP_VERSION}.pkg
BUILD_DIR=build

QT_DIR=$HOME/Qt
QT_ROOT=$QT_DIR/$QT_VER/macos
NINJA_ROOT=$QT_DIR/Tools/Ninja

echo "QT version $QT_VER"

rm -rf $BUILD_DIR

cmake -B $BUILD_DIR -S . -G Ninja --fresh \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
        -DCMAKE_PREFIX_PATH=$QT_ROOT
cmake --build $BUILD_DIR --target all
cmake --build $BUILD_DIR --target update_translations

# Check if the developer ID exists on the system
HAS_DEVELOPER_ID=0; security find-identity -v -p codesigning | grep -q "Developer ID Application: $DEVELOPER_ID" && HAS_DEVELOPER_ID=1

if [ "$HAS_DEVELOPER_ID" -eq 1 ]; then
    echo "Developer ID found. Signing app bundle..."
    codesign --strict --timestamp --force --verify --verbose --deep \
              --entitlements ./Entitlements.plist \
              --sign "Developer ID Application: $DEVELOPER_ID" \
              --options runtime ./build/$APP_NAME.app

    # check the signing
    codesign --verify --verbose=4 --deep --strict ./build/$APP_NAME.app
else
    echo "Developer ID not found. Skipping code signing."
fi

echo "Create installer"
cmake --build $BUILD_DIR --target package

if [ "$HAS_DEVELOPER_ID" -eq 1 ]; then
    echo "Signing installer package..."
    productsign --sign "Developer ID Installer: $DEVELOPER_ID" \
                $BUILD_DIR/$PKG_NAME \
                $PKG_NAME
    mv ${PKG_NAME} $BUILD_DIR/
else
    echo "Developer ID not found. Skipping installer signing."
fi

if [ -z "$APP_PWD" ]; then
     echo Notarization password is not set
     exit 0
fi

echo "Upload installer to Apple servers"
xcrun notarytool submit $BUILD_DIR/$PKG_NAME \
             --apple-id $DEVELOPER_USERNAME \
             --team-id $TEAM_ID \
             --password $APP_PWD \
             --verbose \
             --wait

# once the notarization is successful
echo "Staple the installer"
xcrun stapler staple -v $BUILD_DIR/$PKG_NAME

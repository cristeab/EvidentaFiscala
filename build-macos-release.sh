#!/bin/bash

# $HOME/Qt/$QT_VER/macos/bin/lupdate qml src -ts langs/fr.ts

set -e # exit immeditalley on error

QT_VER=6.7.2
APP_NAME=FiscalRecords
APP_IDENTIFIER="com.cristeab.fiscalrecords"
MAJOR_VERSION=1.1
MINOR_VERSION=$(git rev-list --count HEAD)
APP_VERSION="${MAJOR_VERSION}.${MINOR_VERSION}"

DEVELOPER_ID="Bogdan Cristea"
DEVELOPER_USERNAME="cristeab@gmail.com"
TEAM_ID="FAARUB626Q"
PKG_NAME=${APP_NAME}-${APP_VERSION}.pkg
BUILD_DIR=build

echo "QT version $QT_VER"

rm -rf $BUILD_DIR

mkdir $BUILD_DIR

cmake -B $BUILD_DIR -S . -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH=$HOME/Qt/$QT_VER/macos
cmake --build $BUILD_DIR -j
cmake --build $BUILD_DIR --target deploy

echo "Sign app bundle"
codesign --strict --timestamp --force --verify --verbose --deep \
          --entitlements ./Entitlements.plist \
          --sign "Developer ID Application: $DEVELOPER_ID" \
          --options runtime ./build/$APP_NAME.app

# check the signing
codesign --verify --verbose=4 --deep --strict ./build/$APP_NAME.app

echo "Create installer"
cmake --build $BUILD_DIR --target package

echo "Signing installer package..."
productsign --sign "Developer ID Installer: $DEVELOPER_ID" \
            $BUILD_DIR/$PKG_NAME \
            $PKG_NAME
mv ${PKG_NAME} $BUILD_DIR/

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

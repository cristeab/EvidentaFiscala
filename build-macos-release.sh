#!/bin/bash

set -e # exit immeditalley on error

QT_VER=6.7.0
APP_NAME=EvidentaFiscala
APP_IDENTIFIER="com.cristeab.finance"
MAJOR_VERSION=1.0
MINOR_VERSION=$(git rev-list --count HEAD)
APP_VERSION="${MAJOR_VERSION}.${MINOR_VERSION}"

DEVELOPER_ID="Bogdan Cristea"
DEVELOPER_USERNAME="cristeab@gmail.com"
TEAM_ID="FAARUB626Q"
INSTALL_LOCATION="/Applications"
PKG_NAME=$APP_NAME-$APP_VERSION

echo "QT version $QT_VER"

rm -rf build

mkdir build
pushd build

cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH=$HOME/Qt/$QT_VER/macos
cmake --build . -j
cmake --build . --target pack

popd

# sign bundle AFTER macdeploy
codesign --strict --timestamp --force --verify --verbose --deep \
          --entitlements ./Entitlements.plist \
          --sign "Developer ID Application: $DEVELOPER_ID" \
          --options runtime ./build/$APP_NAME.app

# check the signing
codesign --verify --verbose=4 --deep --strict ./build/$APP_NAME.app

# create installer
pkgbuild --analyze --root build/$APP_NAME.app Components.plist

pkgbuild --identifier $APP_IDENTIFIER \
         --version $APP_VERSION \
         --root build/$APP_NAME.app \
         --component-plist Components.plist \
         --install-location $INSTALL_LOCATION/$APP_NAME.app \
         build/$PKG_NAME.pkg

productbuild --synthesize --package build/$PKG_NAME.pkg distribution.xml

cp build/$PKG_NAME.pkg .
productbuild --distribution distribution.xml \
             --resources . \
             build/$PKG_NAME.pkg
rm $PKG_NAME.pkg

if [ -z "$APP_PWD" ]; then
     echo Notarization password is not set
     exit 0
fi

echo "Upload installer to Apple servers"
xcrun notarytool submit build/$PKG_NAME.pkg \
             --apple-id $DEVELOPER_USERNAME \
             --team-id $TEAM_ID \
             --password $APP_PWD \
             --verbose \
             --wait

# once the notarization is successful
echo "Staple the installer"
xcrun stapler staple -v build/$APP_NAME.dmg

#!/bin/bash

QT_VER=6.4.0
APP_NAME=EvidentaFiscala
APP_IDENTIFIER="com.cristeab.finance"
MAJOR_VERSION=1.0
MINOR_VERSION=$(git rev-list --count HEAD)

echo "QT version $QT_VER"

rm -rf build

mkdir build
cd build

cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH=$HOME/Qt/$QT_VER/macos
make -j
make pack
cd ..

# sign bundle AFTER macdeploy
codesign --strict --timestamp --force --verify --verbose --deep \
          --entitlements ./Entitlements.plist \
          --sign "Developer ID Application: Bogdan Cristea" \
          --options runtime ./build/$APP_NAME.app

 # check the signing
 codesign --verify --verbose=4 --deep --strict ./build/$APP_NAME.app
 if [ $? -ne 0 ]; then
     exit $?
 fi

 # create installer
 rm -f build/$APP_NAME.dmg
 $HOME/node_modules/appdmg/bin/appdmg.js CustomDmg.json build/$APP_NAME.dmg

 if [ -z "$APP_PWD" ]; then
     echo Notarization password is not set
     exit 0
 fi

 echo "Upload installer to Apple servers"
 xcrun altool --notarize-app \
              --primary-bundle-id $APP_IDENTIFIER \
              --username cristeab@gmail.com \
              --password $APP_PWD \
              --asc-provider "FAARUB626Q" \
              --file ./build/$APP_NAME.dmg | tee build/notarization.log
 UUID=`cat build/notarization.log | grep -Eo '\w{8}-(\w{4}-){3}\w{12}$'`
 if [ $? -ne 0 ]; then
     exit $?
 fi

 echo -n "Check notarization result "
 while true; do
     xcrun altool --notarization-info $UUID \
                  --username cristeab@gmail.com \
                  --password $APP_PWD &> build/notarization.log
     r=`cat build/notarization.log`
     t=`echo "$r" | grep "success"`
     f=`echo "$r" | grep "invalid"`
     if [[ "$t" != "" ]]; then
         break
     fi
     if [[ "$f" != "" ]]; then
         echo "failure"
         echo "$r"
         exit 1
     fi
     echo -n "."
     sleep 30
 done
 echo "success"

 # once the notarization is successful
 xcrun stapler staple -v build/$APP_NAME.dmg

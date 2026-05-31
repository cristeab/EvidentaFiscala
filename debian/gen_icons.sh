#!/bin/sh

ORIGICON=../img/logo.png
ORIGICON_SVG=../img/logo.svg

# hicolor
mkdir -p icons/hicolor/symbolic/apps
cp $ORIGICON_SVG icons/hicolor/symbolic/apps/epu-symbolic.svg
for SIZE in 16 32 48 64 128; do
  mkdir -p icons/hicolor/${SIZE}x${SIZE}/apps
  sips -z $SIZE $SIZE $ORIGICON --out icons/hicolor/${SIZE}x${SIZE}/apps/epu.png ;
done

# hicontrast
mkdir -p icons/HighContrast/scalable/apps-extra
cp $ORIGICON_SVG icons/HighContrast/scalable/apps-extra/epu-icon.svg
for SIZE in 16 22 24 32 48 256; do
  mkdir -p icons/HighContrast/${SIZE}x${SIZE}/apps
  sips -z $SIZE $SIZE $ORIGICON --out icons/HighContrast/${SIZE}x${SIZE}/apps/epu.png ;
done


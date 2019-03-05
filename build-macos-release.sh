#!/bin/bash

QT_VER=5.12.1
MAJOR_VERSION=0
MINOR_VERSION=$(git rev-list --count HEAD)

echo "QT version $QT_VER"

rm -rf build

mkdir build
cd build

cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH=$HOME/Qt/$QT_VER/clang_64
make -j
make -j pack

cd ..
mv build/EvidentaFiscala.dmg build/EvidentaFiscala-$MAJOR_VERSION.$MINOR_VERSION.dmg

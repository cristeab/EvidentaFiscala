#!/bin/bash

QT_VER=6.11.1
APP_NAME=FiscalRecords
MAJOR_VERSION=1.3
MINOR_VERSION=$(git rev-list --count HEAD)
APP_VERSION="${MAJOR_VERSION}.${MINOR_VERSION}"

BUILD_DIR=build

QT_DIR=$HOME/Qt
QT_ROOT=$QT_DIR/$QT_VER/gcc_64
NINJA_ROOT=$QT_DIR/Tools/Ninja

echo "QT version $QT_VER"

rm -rf $BUILD_DIR

cmake -B $BUILD_DIR -S . -G Ninja --fresh \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
        -DCMAKE_PREFIX_PATH=$QT_ROOT
cmake --build $BUILD_DIR --target all
cmake --build $BUILD_DIR --target update_translations

echo "Create installer"
cmake --build $BUILD_DIR --target package

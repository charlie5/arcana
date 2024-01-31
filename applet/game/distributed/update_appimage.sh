#!/bin/bash

set -e

echo Updating AppImage.


cp bin/client_partition appimage

pushd appimage
rm -fr AppDir

./linuxdeploy-x86_64.AppImage        \
     --appdir=AppDir                 \
     --executable=./client_partition \
     --create-desktop-file           \
     --icon-file=./client_partition.png

cp  libthai.so  AppDir/usr/lib
cp  libthai.so  AppDir/usr/lib/libthai.so.0

./linuxdeploy-x86_64.AppImage \
     --appdir AppDir          \
     --output appimage

popd


echo Appimage update done.
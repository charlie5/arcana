#!/bin/bash

set -e

clear


## Rebuild distributed arcana.
#
source ~/.gpr_paths.sh
./builder.sh


## Update the appimage.
#
echo
echo
./update_appimage.sh


## Create the client tarball.
#
rm -fr client_tarball
mkdir  client_tarball

cp  --recursive --dereference ../fused/assets       client_tarball
cp  --recursive --dereference ../fused/glade        client_tarball

cp  bin/client_partition                            client_tarball
cp  appimage/client_partition-x86_64.AppImage       client_tarball
cp  polyorb.conf                                    client_tarball

tar  cvzf  client_tarball.tar.gz  client_tarball
cp         client_tarball.tar.gz  /eden/forge/applet/tool/orthanc/applet/server/assets/arcana

rsync  -av  --quiet  client_tarball/*       test/wan_on_orth/client_1
rsync  -av  --quiet  bin/server_partition   test/wan_on_orth/server
rsync  -av  --quiet  bin/server_partition   test/wan_on_orth/server

cp  --recursive --dereference ../fused/assets test/wan_on_orth/server

echo Done.
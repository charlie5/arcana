#!/bin/bash

set -e

rsync -av                \
   client_tarball.tar.gz \
   www.orthanc.site:~/orthanc/applet/server/assets/arcana/

#!/bin/bash

set -e

rsync -av               \
   bin/client_partition \
   www.orthanc.site:~/orthanc/applet/server/assets/arcana/

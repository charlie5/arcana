#!/bin/bash

set -e

rsync -av test/wan/po_namer    www.orthanc.site:~/Desktop/sandbox/arcana
rsync -av test/wan/registrar   www.orthanc.site:~/Desktop/sandbox/arcana
rsync -av bin/server_partition www.orthanc.site:~/Desktop/sandbox/arcana/registrar

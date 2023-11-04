#!/bin/bash

set -e

rsync -av test/wan/po_namer    www.orthanc.site:~/Desktop/sandbox/dsa_template
rsync -av test/wan/registrar   www.orthanc.site:~/Desktop/sandbox/dsa_template
rsync -av bin/server_partition www.orthanc.site:~/Desktop/sandbox/dsa_template/registrar

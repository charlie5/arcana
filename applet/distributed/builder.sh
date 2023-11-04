#!/bin/bash

set -e

export OS=Linux

mkdir -p build

gprclean -r -P launch_arcana
rm -fr dsa



echo __________________________________________________ PHASE 1 _____________________________________________

mkdir --parents  dsa/x86_64-unknown-linux-gnu/obj

cp /usr/lib/gcc/x86_64-pc-linux-gnu/13.2.1/adalib/a-sttebu.ali \
    dsa/x86_64-unknown-linux-gnu/obj

export Build_Mode=debug


set +e
#po_gnatdist -P launch_arcana.gpr arcana.dsa -gnat2022 -cargs -g -largs -g
po_gnatdist -P launch_arcana.gpr arcana.dsa -cargs -g -largs -g
set -e



echo __________________________________________________ PHASE 2 _____________________________________________

cp dsa/x86_64-unknown-linux-gnu/obj/*.o   dsa/x86_64-unknown-linux-gnu/partitions/arcana/server_partition
cp dsa/x86_64-unknown-linux-gnu/obj/*.o   dsa/x86_64-unknown-linux-gnu/partitions/arcana/client_partition

po_gnatdist  -Xrestrictions=xgc -Xopengl_platform=egl -Xopengl_profile=lean -P launch_arcana.gpr  arcana.dsa 



#rm -fr build
#rm -fr dsa


echo Done.
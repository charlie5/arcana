#!/bin/bash

set -e

export OS=Linux

mkdir -p build

gprclean -r -P launch_chat


rm -fr dsa
mkdir --parents  dsa/x86_64-unknown-linux-gnu/obj
cp /usr/lib/gcc/x86_64-pc-linux-gnu/13.2.1/adalib/a-sttebu.ali dsa/x86_64-unknown-linux-gnu/obj

export Build_Mode=debug
#po_gnatdist -P launch_chat.gpr chat.dsa -gnat2022 -cargs -g -largs -g
po_gnatdist -P launch_chat.gpr chat.dsa -cargs -g -largs -g

#rm -fr build
#rm -fr dsa

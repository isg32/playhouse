#!/bin/bash

echo """
====================================
    CUAOSP BUILDER FOR HANOIP
====================================
LETS GET RUSTY SHALL WE?
"""

echo """
What are we building today? 

 [1] Android 14 CUAOSP
 [2] Android 15 CUAOSP-BETA
"""
read xyz

if [ "$xyz" == '1' ]; then
    bash ./Custom-ROMS/cuaosp14.sh
elif [ "$xyz" == '2' ]; then
    bash ./Custom-ROMS/cuaosp15.sh
fi

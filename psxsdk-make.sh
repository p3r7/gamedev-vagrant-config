#!/bin/bash

# -*- mode: shell-script -*-

# TODO: truncate if project name is more than 8 letters

# we must have a "cdimg" or "cdroot" folder
PROJECT_NAME=$(basename $PWD)
PROJECT_NAME_TRUNCATED=$(echo $PROJECT_NAME | cut -c 1-8)

CD_LICENSE_FILE=/usr/local/psxsdk/share/licenses/infoeur.dat

RUN_METHOD=pSX
# RUN_METHOD=pcsx

if [ -d "$PWD/cdimg" ] ; then
    ISO_HEADER_LOCATION="cdimg"
elif [ -d "$PWD/cd_root" ] ; then
    ISO_HEADER_LOCATION="cd_root"
else
    # default
    mkdir "$PWD/cd_root"
    ISO_HEADER_LOCATION="cd_root"
fi


## compile into a .ELF
# TODO: enable compiler optimization:
# psx-gcc -O3 $(CFLAGS) -DEXAMPLES_VMODE=$(EXAMPLES_VMODE) -o mandel.elf mandel.c
if [ -d "$PWD/src" ] ; then
    psx-gcc -o $PROJECT_NAME_TRUNCATED.elf src/*.c -lm
else
    #psx-gcc -o $(ls *.c | sed 's/.c//').elf *.c -lm
    psx-gcc -O3 -o $PROJECT_NAME_TRUNCATED.elf *.c -lm
fi

## .EXE
elf2exe $PROJECT_NAME_TRUNCATED.elf $PROJECT_NAME_TRUNCATED.exe -mark_eur


## resources
systemcnf $PROJECT_NAME_TRUNCATED.exe > $ISO_HEADER_LOCATION/system.cnf
cp $PROJECT_NAME_TRUNCATED.exe $ISO_HEADER_LOCATION
# TODO: change it to support multiple .bmp, using a list
LIST_BMP=$(ls *.bmp)
for bmp in $LIST_BMP; do
    bmp2tim $bmp $ISO_HEADER_LOCATION/$(echo $bmp | sed 's/.bmp//').tim 16 -org=320,0
done

## (unsigned ?) .ISO
mkisofs -o $PROJECT_NAME.iso -V $(echo "$PROJECT_NAME" | tr '[:lower:]' '[:upper:]') -sysid PLAYSTATION $ISO_HEADER_LOCATION

## (signed ?) .BIN/.CUE
mkpsxiso $PROJECT_NAME.iso $PROJECT_NAME.bin $CD_LICENSE_FILE

if [ "$1" = "run" ]; then
    if [ "$RUN_METHOD" = "pSX" ]; then
	pSX $(ls *.bin)
    elif [ "$RUN_METHOD" = "pcsx" ]; then
	padsp pcsx -cdfile "$(ls *.bin)" -nogui
    fi
fi

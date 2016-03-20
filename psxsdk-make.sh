#!/bin/bash

# -*- mode: shell-script -*-

# -------------------------------------------------------------------------

# PARAMETERS

PROJECT_NAME=$(basename $PWD)
PROJECT_NAME_TRUNCATED=$(echo $PROJECT_NAME | cut -c 1-8)

CD_LICENSE_FILE=/usr/local/psxsdk/share/licenses/infoeur.dat

OUTPUT_FOLDER_NAME=target
OUTPUT_FOLDER_PATH="$PWD/$OUTPUT_FOLDER_NAME"
OUTPUT_PACKAGE_FOLDER_NAME=cd_root
OUTPUT_PACKAGE_FOLDER_PATH="$OUTPUT_FOLDER_PATH/$OUTPUT_PACKAGE_FOLDER_NAME"

RSC_IMG_FOLDER_PATH="$PWD/rsc/img"

RUN_METHOD=pSX
# RUN_METHOD=pcsx
# RUN_METHOD=xebra


# -------------------------------------------------------------------------

# create necessary folders

if [ ! -d "$OUTPUT_FOLDER_PATH" ] ; then
    mkdir "$OUTPUT_FOLDER_PATH"
else
    rm -Rf "$OUTPUT_FOLDER_PATH/*"
fi

if [ ! -d "$OUTPUT_PACKAGE_FOLDER_PATH" ] ; then
    mkdir "$OUTPUT_PACKAGE_FOLDER_PATH"
else
    rm -Rf "$OUTPUT_PACKAGE_FOLDER_PATH/*"
fi


# -------------------------------------------------------------------------

# src location detection

if [ -d "$PWD/src" ] ; then
    SRC_FOLDER="$PWD/src"
else
    SRC_FOLDER="$PWD"
fi


# -------------------------------------------------------------------------

# src -> .ELF

# TODO: enable compiler optimization:
# psx-gcc -O3 $(CFLAGS) -DEXAMPLES_VMODE=$(EXAMPLES_VMODE) -o mandel.elf mandel.c

#psx-gcc -o $(ls *.c | sed 's/.c//').elf *.c -lm
psx-gcc -o "$OUTPUT_FOLDER_PATH/$PROJECT_NAME_TRUNCATED.elf" "$SRC_FOLDER/*.c" -lm


# -------------------------------------------------------------------------

# .ELF -> .EXE

elf2exe "$OUTPUT_FOLDER_PATH/$PROJECT_NAME_TRUNCATED.elf" "$OUTPUT_FOLDER_PATH/$PROJECT_NAME_TRUNCATED.exe" -mark_eur
cp "$OUTPUT_FOLDER_PATH/$PROJECT_NAME_TRUNCATED.exe" "$OUTPUT_PACKAGE_FOLDER_PATH"


# -------------------------------------------------------------------------

# .CFN (iso header file)

cd "$OUTPUT_PACKAGE_FOLDER_PATH"
systemcnf "$PROJECT_NAME_TRUNCATED.exe" > system.cnf
cd -

# -------------------------------------------------------------------------

## img convertions

if [ -d "$RSC_IMG_FOLDER_PATH" ] ; then
    cd "$RSC_IMG_FOLDER_PATH"
    LIST_BMP=$(ls *.bmp)
    for bmp in $LIST_BMP; do
	bmp2tim $bmp $OUTPUT_PACKAGE_FOLDER_PATH/$(echo $bmp | sed 's/.bmp//').tim 16 -org=320,0
    done
    cd -
fi


# -------------------------------------------------------------------------

# .EXE / .CFN / resources -> (unsigned) .ISO

mkisofs -o "$OUTPUT_FOLDER_PATH/$PROJECT_NAME.iso" -V $(echo "$PROJECT_NAME" | tr '[:lower:]' '[:upper:]') -sysid PLAYSTATION "$OUTPUT_PACKAGE_FOLDER_PATH"


# -------------------------------------------------------------------------

# (unsigned) .ISO -> .BIN / .CUE
mkpsxiso "$OUTPUT_FOLDER_PATH/$PROJECT_NAME.iso" "$OUTPUT_FOLDER_PATH/$PROJECT_NAME.bin" "$CD_LICENSE_FILE"


# -------------------------------------------------------------------------

# optional run command

if [ "$1" = "run" ]; then
    if [ "$RUN_METHOD" = "pSX" ]; then
	pSX $(ls *.bin)
    elif [ "$RUN_METHOD" = "pcsx" ]; then
	padsp pcsx -cdfile "$(ls *.bin)" -nogui
    fi
fi

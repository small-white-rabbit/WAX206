#!/bin/sh

. ./flash.info

# Modify input/output image name
INPUT_NAME=$1
OUTPUT_NAME=$2

./sbch e "$FLASH_NAME" "$INPUT_NAME" "$OUTPUT_NAME" 0 0 0



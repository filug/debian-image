#!/bin/bash

WORK_DIR=$1
PATCH_FILE=$2

PATCH_NAME=$(basename ${PATCH_FILE})

echo "Applying patch: ${PATCH_NAME}"
patch -g0 -p1 -E -d ${WORK_DIR} -t -N < ${PATCH_FILE}

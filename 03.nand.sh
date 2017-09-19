#!/bin/bash

CHIP_TOOLS_PATH="CHIP-SDK/CHIP-tools"
UBOOT_PATH="../CHIP-buildroot/output/build/uboot-nextthing_2016.01_next"
ROOTFS_PATH="../../rootfs.tar"

cd $CHIP_TOOLS_PATH
rm -rf new-image # delete any old image
sudo ./chip-create-nand-images.sh $UBOOT_PATH $ROOTFS_PATH new-image

echo "new-image in CHIP-SDK/CHIP-tools!!!"

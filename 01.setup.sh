#!/bin/bash
# This script will pull in the CHIP-SDK, and then unpack it.
# Some things will be downloaded, compiled, and installed so it may ask for
# your password.
HERE="$PWD"

if [ ! -d "$HERE/CHIP-SDK" ] ; then
  git clone https://github.com/nextthingco/CHIP-SDK
fi
cd "$HERE/CHIP-SDK"
bash setup_ubuntu1404.sh

sed -i 's/atenart/nextthingco/' CHIP-buildroot/package/dtc-overlay/dtc-overlay.mk

# multistrap dependencies
sudo apt-get install multistrap qemu-user-static live-build

#patch multistrap
sudo sed -i 's/\$forceyes //' /usr/sbin/multistrap

cd $HERE
git clone https://github.com/NextThingCo/CHIP-linux.git --single-branch --branch nextthing/4.4/chip --depth 1
echo "BR2_LINUX_KERNEL_CUSTOM_LOCAL=y" >> $HERE/CHIP-SDK/CHIP-buildroot/configs/chippro_defconfig
echo "BR2_LINUX_KERNEL_CUSTOM_LOCAL_PATH=\"$HERE/CHIP-linux\"" >> $HERE/CHIP-SDK/CHIP-buildroot/configs/chippro_defconfig

#sed -i "/^BR2_LINUX_KERNEL_CUSTOM_LOCAL_PATH=/cBR2_LINUX_KERNEL_CUSTOM_LOCAL_PATH=\"$HERE/CHIP-linux\""  $HERE/CHIP-SDK/CHIP-buildroot/configs/chippro_defconfig

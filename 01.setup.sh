#!/bin/bash
# This script will pull in the CHIP-SDK, and then unpack it.
# Some things will be downloaded, compiled, and installed so it may ask for
# your password.

if [ ! -d "$PWD/CHIP-SDK" ] ; then
  git clone https://github.com/nextthingco/CHIP-SDK
fi
cd "$PWD/CHIP-SDK"
bash setup_ubuntu1404.sh

sed -i 's/atenart/nextthingco/' CHIP-buildroot/package/dtc-overlay/dtc-overlay.mk

# multistrap dependencies
sudo apt-get install multistrap qemu-user-static live-build

#patch multistrap
sudo sed -i 's/\$forceyes //' /usr/sbin/multistrap

cd -
git clone https://github.com/NextThingCo/CHIP-linux.git
cd "$PWD/CHIP-linux"
git checkout nextthing/4.4/chi

cd "$PWD/CHIP-SDK/CHIP-buildroot"
git apply $PWD/01.patch

cd "$PWD/CHIP-linux"
git apply $PWD/02.patch

sed -i "/^BR2_LINUX_KERNEL_CUSTOM_LOCAL_PATH=/cBR2_LINUX_KERNEL_CUSTOM_LOCAL_PATH=\"$PWD/CHIP-linuxaaa\""  $PWD/CHIP-SDK/CHIP-buildroot/configs/chippro_defconfig

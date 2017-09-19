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


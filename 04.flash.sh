#!/bin/bash
# Flash the NAND image stored by new-image/ to any attached FEL device. 

CHIP_TOOLS_PATH="$PWD/CHIP-SDK/CHIP-tools"
cd $CHIP_TOOLS_PATH
bash ./chip-flash-nand-images.sh ./new-image

#!/bin/bash
# Brief
# This script will create a bootable custom Linux image that can be flashed to
# a CHIP Pro using the command line utilities in CHIP-tools.

# Usage:
# sh buildroot-rootfs.sh multistrap.conf
#     Where multistrap.conf is the relative path to the multistrap config
#     file you want to build your CHIP Pro image according to.

HERE="$PWD"
MULTISTRAP_CONF_FILE="$1"
ROOTFS_DIR="$HERE/rootfs"
SDK_PATH="$HERE/CHIP-SDK"
BUILDROOT_PATH="$SDK_PATH/CHIP-buildroot"

# This compiles CHIP-buildroot and decompresses the resulting rootfs
# into the CHIP-buildroot/buildroot-rootfs directory for later reference.
# Note: This can take a LONG time! Even on a powerful machine.
compile_chip_buildroot () {
  cd $BUILDROOT_PATH
  make chippro_defconfig
  make
  sudo rm -rf buildroot-rootfs
  mkdir buildroot-rootfs
  sudo tar -xf $BUILDROOT_PATH/output/images/rootfs.tar -C ./buildroot-rootfs
  cd -
}

# Copy over relevant kernel and kernel modules for the CHIP Pro board
# from the CHIP-buildroot rootfs
copy_boot_modules () {
  cp -r $BUILDROOT_PATH/buildroot-rootfs/boot/* $ROOTFS_DIR/boot/
  cp -r $BUILDROOT_PATH/buildroot-rootfs/lib/modules $ROOTFS_DIR/lib/
}

# Create a rootfs using multistrap and clean any old data
create_rootfs () {
  sudo umount -l $ROOTFS_DIR/proc && sudo umount -f $ROOTFS_DIR/proc
  sudo rm -rf $HERE/rootfs.tar $ROOTFS_DIR
  multistrap -f $MULTISTRAP_CONF_FILE -d $ROOTFS_DIR
  copy_boot_modules
  sudo chown -R $USER:$USER $ROOTFS_DIR
}

chroot_exec () {
  LC_ALL=C LANGUAGE=C LANG=C sudo chroot $ROOTFS_DIR qemu-arm-static /bin/bash -c "$@"
}

# This ensures that sudo has the correct permissions to execute on the target.
# This is required or you're gonna have a bad time!
fix_sudo () {
  for FILE in /usr/bin/sudo /usr/lib/sudo/sudoers.so /etc/sudoers /etc/sudoers.d /etc/sudoers.d/README /var/lib/sudo
  do
    sudo chown root:root $ROOTFS_DIR$FILE
    sudo chmod 4755 $ROOTFS_DIR$FILE
  done
}

# This provides our target rootfs's rc.local.
write_rclocal () {
  echo "#!/bin/sh -e
#
# rc.local
#
# This script is executed at the end of each multiuser runlevel.
# Make sure that the script will "exit 0" on success or any other
# value on error.
#
# In order to enable or disable this script just change the execution
# bits.
#
# By default this script does nothing.
exit 0" | tee $ROOTFS_DIR/etc/rc.local
}

# Copy over interface and other networking files
install_network_config () {
  # Fix DNS resolution
  echo "nameserver 8.8.8.8" | tee $ROOTFS_DIR/etc/resolv.conf

  # Customize /etc/network/interfaces
  #cp $RESOURCES_DIR/config/interfaces $ROOTFS_DIR/etc/network/interfaces
echo "auto lo
iface lo inet loopback

allow-hotplug wlan0
iface wlan0 inet dhcp

allow-hotplug wlan1
iface wlan1 inet dhcp" | tee $ROOTFS_DIR/etc/network/interfaces

}

# An example of how to install precompiled software.
# In this case we're just decompressing nodejs into an installation target.
#install_nodejs () {
#  mkdir -p $ROOTFS_DIR/usr/local
#  tar --strip-components 1 -xzf $RESOURCES_DIR/precompiled/node-v6.10.2-linux-armv7l.tar.gz -C $ROOTFS_DIR/usr/local/
#}

# Ensure the target system is using python2.7
replace_python () {
  chroot_exec "ln -s /usr/bin/python2.7 /usr/bin/python"
}

configure_rootfs () {

  # Some examples of installing custom user binaries or scripts.
  #install_nodejs

  # Fix sudo & binary permissions
  #Required.
  sudo chown root:root -R $ROOTFS_DIR/bin $ROOTFS_DIR/usr/bin $ROOTFS_DIR/usr/sbin
  fix_sudo
  sudo cp /usr/bin/qemu-arm-static $ROOTFS_DIR/usr/bin

  # Complete Debian package installation and configuration
  # Required.
  chroot_exec "dpkg --configure -a"

  # Make sure we are using python 2.7 as default!
  replace_python

  # Network interface, DNS resolution, et cetera...
  install_network_config

  # Customize rc.local
  write_rclocal

  # Set password of root user
  # Required.
  echo "Set root password:"
  chroot_exec "echo root:password | /usr/sbin/chpasswd"

  # Create new non-root user
  # Ensure this user can use sudo
  chroot_exec "useradd -m -s /bin/bash -G sudo zhangranrui"

}

tar_rootfs () {
  cd $ROOTFS_DIR
  sudo tar -cf ../rootfs.tar .
  cd -
}

#if [ ! -d "$BUILDROOT_PATH/buildroot-rootfs" ] ; then
compile_chip_buildroot
#fi
create_rootfs
configure_rootfs
tar_rootfs

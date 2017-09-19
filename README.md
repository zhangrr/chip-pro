# CHIP Pro内核和文件系统编译

## 环境准备
系统：ubuntu-16.04.3-desktop-amd64.iso

如下配置网卡
```bash
apt install openssh-server

cat << EOF >> /etc/network/interfaces
auto ens3
iface ens3 inet static
address 192.168.1.100
netmask 255.255.254.0
gateway 192.168.2.254
dns-nameservers 192.168.1.1
dns-nameservers 192.168.1.2
EOF

reboot
```

## 安装
```bash
git clone https://github.com/zhangrr/chip-pro
cd chip-pro
sh 01.setup.sh
```

## 编译内核和文件系统
配置文件是 multistrap-config-examples/debian-netutils.conf

```bash
sh 02.create-chip-rootfs.sh multistrap-config-examples/debian-netutils.conf
```

会在目录下生成一个 `rootfs.tar` 文件

## 建立一个可烧录的 NAND 镜像
```bash
sh 03.nand.sh
```

## 烧录
```bash
sh 04.flash.sh
```

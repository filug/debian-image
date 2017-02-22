DL_DIR = $(PWD)/dl
OUTPUT_DIR = $(PWD)/output
OUTPUT_IMAGES_DIR = $(OUTPUT_DIR)/images

ROOTFS = $(OUTPUT_DIR)/rootfs
ROOTFS_IMAGE = $(OUTPUT_IMAGES_DIR)/rootfs.ext4

ARCH = arm
CROSS_COMPILE ?= arm-linux-gnueabi-

JOBS = 4

#LINUX_VERSION = 4.9.11
LINUX_VERSION = 4.8

LINUX_PATCHES_DIR = patches/linux

#LINUX_CONFIG        = imx_v6_v7_defconfig
LINUX_CONFIG_CUSTOM = configs/linux_defconfig

LINUX_DTS        = imx6ul-liteboard.dts
#LINUX_DTS_CUSTOM = configs/imx6ul-liteboard.dts


UBOOT_VERSION = 2017.01
UBOOT_CONFIG  = liteboard_defconfig

MULTISTRAP_ARCH = armhf
MULTISTRAP_CONF = multistrap.conf
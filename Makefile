include config.mk
include debian.mk
include u-boot.mk
include linux.mk
include genimage.mk

all: uboot debian linux rootfs_image genimage
	echo "complete build"


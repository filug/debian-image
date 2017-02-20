include config.mk
include debian.mk
include u-boot.mk
include linux.mk


all: uboot debian linux 
	echo "complete build"


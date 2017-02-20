include config.mk
include tools.mk


#DEBIAN_STAMP_EXTRACTED  = $(ROOTFS)/.stamp_extracted


debian:
ifeq ($(wildcard $(ROOTFS)),)
	sudo multistrap -a $(MULTISTRAP_ARCH) -f $(MULTISTRAP_CONF)
	sudo cp /usr/bin/qemu-arm-static $(ROOTFS)/usr/bin/
	sudo mount -o bind /dev/ $(ROOTFS)/dev/
	sudo LC_ALL=C LANGUAGE=C LANG=C chroot $(ROOTFS) mount -t proc nodev /proc
	sudo LC_ALL=C LANGUAGE=C LANG=C chroot $(ROOTFS) dpkg --configure -a
	sudo LC_ALL=C LANGUAGE=C LANG=C chroot $(ROOTFS) umount /proc
	sudo umount $(ROOTFS)/dev/
	sudo rm $(ROOTFS)/usr/bin/qemu-arm-static
endif

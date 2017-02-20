include config.mk
include tools.mk

LINUX_DL_LINK = https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-$(LINUX_VERSION).tar.xz
LINUX_DL_SRC  = $(DL_DIR)/linux-$(LINUX_VERSION).tar.xz
LINUX_OUT_SRC = $(OUTPUT_DIR)/linux-$(LINUX_VERSION)

ifdef LINUX_DTS_CUSTOM
LINUX_DTB     = $(subst .dts,.dtb,$(notdir $(LINUX_DTS_CUSTOM)))
else
LINUX_DTB     = $(subst .dts,.dtb,$(notdir $(LINUX_DTS)))
endif


ifdef LINUX_PATCHES_DIR
LINUX_PATCHES := $(shell find $(LINUX_PATCHES_DIR) -name '*.patch')
endif


LINUX_STAMP_EXTRACTED  = $(LINUX_OUT_SRC)/.stamp_extracted
LINUX_STAMP_PATCHED    = $(LINUX_OUT_SRC)/.stamp_patched
LINUX_STAMP_CONFIGURED = $(LINUX_OUT_SRC)/.stamp_configured
LINUX_STAMP_BUILT      = $(LINUX_OUT_SRC)/.stamp_built
LINUX_STAMP_INSTALLED  = $(LINUX_OUT_SRC)/.stamp_installed


###########################
# Download kernel sources #
###########################
linux-download: download-pre
ifeq ($(wildcard $(LINUX_DL_SRC)),)
	$(call banner,"Linux downloading ...")
	$(call download,$(LINUX_DL_LINK),$(LINUX_DL_SRC))
	$(call banner,"Linux downloading DONE")
endif

#####################################
# Extract downloaded kernel sources #
#####################################
linux-extract: linux-download
ifeq ($(wildcard $(LINUX_STAMP_EXTRACTED)),)
	$(call banner,"Linux extracting ...")
	tar xf $(LINUX_DL_SRC) -C $(OUTPUT_DIR)
	touch $(LINUX_STAMP_EXTRACTED)
	$(call banner,"Linux extracting DONE")
endif


#################
# Apply patches #
#################
linux-patch: linux-extract
ifeq ($(wildcard $(LINUX_STAMP_PATCHED)),)
ifdef LINUX_PATCHES
	$(call banner,"Linux patching ...")
	$(foreach patch,$(sort $(LINUX_PATCHES)),tools/apply-patch.sh $(LINUX_OUT_SRC) $(patch);)
#	$(foreach patch,$(sort $(LINUX_PATCHES)),$(call apply-patch,$(LINUX_OUT_SRC),$(patch)))
	$(call banner,"Linux patching DONE")
endif
	touch $(LINUX_STAMP_PATCHED)
endif



####################
# Configure kernel #
####################
linux-configure: linux-download linux-patch linux-extract
ifeq ($(wildcard $(LINUX_STAMP_CONFIGURED)),)
	$(call banner,"Linux configuration ...")

ifdef LINUX_CONFIG_CUSTOM
#   apply custom configuration
	cp $(LINUX_CONFIG_CUSTOM) $(LINUX_OUT_SRC)/.config
	cd $(LINUX_OUT_SRC) && make ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) olddefconfig
else
#   use build-in configuration
	cd $(LINUX_OUT_SRC) && make ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) $(LINUX_CONFIG)
endif

ifdef LINUX_DTS_CUSTOM
#   copy custom device tree file
	cp $(LINUX_DTS_CUSTOM) $(LINUX_OUT_SRC)/arch/$(ARCH)/boot/dts/
endif

	touch $(LINUX_STAMP_CONFIGURED)
	$(call banner,"Linux configuration DONE")
endif

################
# Build kernel #
################
linux-build: linux-configure
ifeq ($(wildcard $(LINUX_STAMP_BUILT)),)
	$(call banner,"Linux compilation ...")
#   compile kernel
	cd $(LINUX_OUT_SRC) && make ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) -j$(JOBS) all
#	compile modules
	cd $(LINUX_OUT_SRC) && make ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) -j$(JOBS) modules
#   compile device tree file
	cd $(LINUX_OUT_SRC) && make ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) $(LINUX_DTB)
	
	touch $(LINUX_STAMP_BUILT)
	$(call banner,"Linux compilation DONE")
endif


##################
# Install kernel #
##################
linux: install-pre linux-build
ifeq ($(wildcard $(LINUX_STAMP_INSTALLED)),)
	$(call banner,"Linux installation ...")
	cp $(LINUX_OUT_SRC)/arch/$(ARCH)/boot/zImage $(OUTPUT_IMAGES_DIR)
	cp $(LINUX_OUT_SRC)/arch/$(ARCH)/boot/dts/$(LINUX_DTB) $(OUTPUT_IMAGES_DIR)
	
	cd $(LINUX_OUT_SRC) && sudo make ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) INSTALL_MOD_PATH=$(ROOTFS) modules_install

	touch $(LINUX_STAMP_INSTALLED)
	$(call banner,"Linux installation DONE")
endif






#############################
# Show kernel configuration #
#############################
linux-menuconfig: linux-configure
	cd $(LINUX_OUT_SRC) && make ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) menuconfig
	rm -f $(LINUX_STAMP_BUILT)
	rm -f $(LINUX_STAMP_INSTALLED)

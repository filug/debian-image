include config.mk
include tools.mk

UBOOT_DL_LINK = ftp://ftp.denx.de/pub/u-boot/u-boot-$(UBOOT_VERSION).tar.bz2
UBOOT_DL_SRC  = $(DL_DIR)/u-boot-$(UBOOT_VERSION).tar.bz2
UBOOT_OUT_SRC = $(OUTPUT_DIR)/u-boot-$(UBOOT_VERSION)

ifdef UBOOT_PATCHES_DIR
UBOOT_PATCHES := $(shell find $(UBOOT_PATCHES_DIR) -name '*.patch')
endif

UBOOT_STAMP_EXTRACTED  = $(UBOOT_OUT_SRC)/.stamp_extracted
UBOOT_STAMP_PATCHED    = $(UBOOT_OUT_SRC)/.stamp_patched
UBOOT_STAMP_CONFIGURED = $(UBOOT_OUT_SRC)/.stamp_configured
UBOOT_STAMP_BUILT      = $(UBOOT_OUT_SRC)/.stamp_built
UBOOT_STAMP_INSTALLED  = $(UBOOT_OUT_SRC)/.stamp_installed


####################
# Download sources #
####################
uboot-download: download-pre
ifeq ($(wildcard $(UBOOT_DL_SRC)),)
	$(call banner,"U-Boot downloading ...")
	$(call download,$(UBOOT_DL_LINK),$(UBOOT_DL_SRC))
	$(call banner,"U-Boot downloading DONE")
endif

##############################
# Extract downloaded sources #
##############################
uboot-extract: uboot-download
ifeq ($(wildcard $(UBOOT_STAMP_EXTRACTED)),)
	$(call banner,"U-Boot extracting ...")
	tar xf $(UBOOT_DL_SRC) -C $(OUTPUT_DIR)
	touch $(UBOOT_STAMP_EXTRACTED)
	$(call banner,"U-Boot extracting DONE")
endif


#################
# Apply patches #
#################
uboot-patch: uboot-extract
ifeq ($(wildcard $(UBOOT_STAMP_PATCHED)),)
ifdef UBOOT_PATCHES
	$(call banner,"U-Boot patching ...")
	$(foreach patch,$(sort $(UBOOT_PATCHES)),tools/apply-patch.sh $(UBOOT_OUT_SRC) $(patch);)
	$(call banner,"U-Boot patching DONE")
endif
	touch $(UBOOT_STAMP_PATCHED)
endif



#############
# Configure #
#############
uboot-configure: uboot-download uboot-patch uboot-extract
ifeq ($(wildcard $(UBOOT_STAMP_CONFIGURED)),)
	$(call banner,"U-Boot configuration ...")

ifdef UBOOT_CONFIG_CUSTOM
#   apply custom configuration
	cp $(UBOOT_CONFIG_CUSTOM) $(UBOOT_OUT_SRC)/.config
	cd $(UBOOT_OUT_SRC) && make ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) olddefconfig
else
#   use build-in configuration
	cd $(UBOOT_OUT_SRC) && make ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) $(UBOOT_CONFIG)
endif

	touch $(UBOOT_STAMP_CONFIGURED)
	$(call banner,"U-Boot configuration DONE")
endif


#########
# Build #
#########
uboot-build: uboot-configure
ifeq ($(wildcard $(UBOOT_STAMP_BUILT)),)
	$(call banner,"U-Boot compilation ...")
#   compile kernel
	cd $(UBOOT_OUT_SRC) && make ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) -j$(JOBS) all
	
	touch $(UBOOT_STAMP_BUILT)
	$(call banner,"U-Boot compilation DONE")
endif


###########
# Install #
###########
uboot: install-pre uboot-build
ifeq ($(wildcard $(UBOOT_STAMP_INSTALLED)),)
	$(call banner,"U-Boot installation ...")
	cp $(UBOOT_OUT_SRC)/u-boot.img $(OUTPUT_IMAGES_DIR)
	cp $(UBOOT_OUT_SRC)/SPL $(OUTPUT_IMAGES_DIR)

	touch $(UBOOT_STAMP_INSTALLED)
	$(call banner,"U-Boot installation DONE")
endif






#############################
# Show kernel configuration #
#############################
uboot-menuconfig: uboot-configure
	cd $(UBOOT_OUT_SRC) && make ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) menuconfig
	rm -f $(UBOOT_STAMP_BUILT)
	rm -f $(UBOOT_STAMP_INSTALLED)

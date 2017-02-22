include config.mk


GENIMAGE_VERSION = 9


GENIMAGE_DL_LINK = http://public.pengutronix.de/software/genimage/genimage-$(GENIMAGE_VERSION).tar.xz
GENIMAGE_DL_SRC  = $(DL_DIR)/genimage-$(GENIMAGE_VERSION).tar.xz
GENIMAGE_OUT_SRC = $(OUTPUT_DIR)/genimage-$(GENIMAGE_VERSION)

GENIMAGE_STAMP_EXTRACTED  = $(GENIMAGE_OUT_SRC)/.stamp_extracted
GENIMAGE_STAMP_BUILT      = $(GENIMAGE_OUT_SRC)/.stamp_built
GENIMAGE_STAMP_INSTALLED  = $(GENIMAGE_OUT_SRC)/.stamp_installed



genimage-download:
ifeq ($(wildcard $(GENIMAGE_DL_SRC)),)
	$(call banner,"Genimage downloading ...")
	$(call download,$(GENIMAGE_DL_LINK),$(GENIMAGE_DL_SRC))
	$(call banner,"Genimage downloading DONE")
endif

genimage-extract: genimage-download
ifeq ($(wildcard $(GENIMAGE_STAMP_EXTRACTED)),)
	$(call banner,"Genimage extracting ...")
	tar xf $(GENIMAGE_DL_SRC) -C $(OUTPUT_DIR)
	touch $(GENIMAGE_STAMP_EXTRACTED)
	$(call banner,"Genimage extracting DONE")
endif

genimage-build: genimage-extract
ifeq ($(wildcard $(GENIMAGE_STAMP_BUILT)),)
	$(call banner,"Genimage building ...")
	cd $(GENIMAGE_OUT_SRC) && ./configure
	cd $(GENIMAGE_OUT_SRC) && make
	touch $(GENIMAGE_STAMP_BUILT)
	$(call banner,"Genimage building DONE")
endif


genimage: genimage-build
	mkdir -p foo
	sudo $(GENIMAGE_OUT_SRC)/genimage --config genimage.cfg  --tmppath foo --outputpath $(OUTPUT_IMAGES_DIR) --inputpath $(OUTPUT_IMAGES_DIR) --rootpath $(ROOTFS)
	sudo rm -rf foo




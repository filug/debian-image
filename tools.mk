define download
	@echo "Downloading $(1)"
	wget -q --show-progress $(1) -O $(2)
endef

define banner
	@echo "#############################################"
	@echo "# $(1)"
	@echo "#############################################"
endef

download-pre:
ifeq ($(wildcard $(DL_DIR)),)
	mkdir -p $(DL_DIR)
endif

install-pre:
ifeq ($(wildcard $(OUTPUT_IMAGES_DIR)),)
	mkdir -p $(OUTPUT_IMAGES_DIR)
endif


#APPLY_PATCH := $(shell echo "$(patch)")

#define apply-patch
#	patch -g0 -p1 -E -d $(1) -t -N < $(2);
#endef
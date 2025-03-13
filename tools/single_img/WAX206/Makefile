CURRDIR := $(shell pwd)
MODEL = $(shell cat model 2>/dev/null)
BLOCKSIZE = $(shell cat blocksize 2>/dev/null)
REGION = $(shell cat region 2>/dev/null)
VERSION = $(shell cat version 2>/dev/null)
INSTALLDIR = $(shell cat bindir 2>/dev/null)

UPDATEFILE = $(MODEL)-$(VERSION)-SingleUpdate.img
KERNEL_FILE = $(MODEL)-$(VERSION).img
BOOT_KERNEL_FILE = $(MODEL)-$(VERSION)-Boot.img
UNENCRYPTED_UPDATEFILE = $(MODEL)-UNENCRYPTED-SingleUpdate.img
UNENCRYPTED_KERNEL_FILE = $(MODEL)-UNENCRYPTED.img
UNENCRYPTED_BOOT_KERNEL_FILE = $(MODEL)-UNENCRYPTED-Boot.img
BURNFILE = $(MODEL)-$(VERSION)-FlashBurn.img
export IMAGE_TAG

image.oob:
	@if [ -z $(MODEL) ] || [ -z $(BLOCKSIZE) ] || [ -z $(REGION) ] || [ -z $(VERSION) ] || [ -z $(INSTALLDIR) ];then \
		echo "Please run make first!";\
		exit 1;\
	fi
	@echo "make $(MODEL) image"
	@cp $(SDKDIR)/../bootloader/Uboot-arm/u-boot-mtk.bin  $(CURRDIR)/u-boot-mtk.bin
	$(CURRDIR)/mk_single_img.sh $(UPDATEFILE) $(KERNEL_FILE) $(BOOT_KERNEL_FILE) $(BURNFILE)
	$(CURRDIR)/../../../staging_dir/host/bin/imgencoder \
		--encode $(CURRDIR)/$(UPDATEFILE) \
		--blocksize $(BLOCKSIZE) \
		--region $(REGION) \
		--model $(MODEL) \
		--sw_version $(VERSION) \
		--output $(CURRDIR)/$(UPDATEFILE).new \
		--prikey $(CURRDIR)/private.key
	$(CURRDIR)/../../../staging_dir/host/bin/imgencoder \
		--encode $(CURRDIR)/$(KERNEL_FILE) \
		--blocksize $(BLOCKSIZE) \
		--region $(REGION) \
		--model $(MODEL) \
		--sw_version $(VERSION) \
		--output $(CURRDIR)/$(KERNEL_FILE).new \
		--prikey $(CURRDIR)/private.key
	$(CURRDIR)/../../../staging_dir/host/bin/imgencoder \
		--encode $(CURRDIR)/$(BOOT_KERNEL_FILE) \
		--blocksize $(BLOCKSIZE) \
		--region $(REGION) \
		--model $(MODEL) \
		--sw_version $(VERSION) \
		--output $(CURRDIR)/$(BOOT_KERNEL_FILE).new \
		--prikey $(CURRDIR)/private.key
	@if [ -f $(BURNFILE) ];then \
		cp $(BURNFILE) $(INSTALLDIR)/$(BURNFILE);\
		rm $(BURNFILE)*;\
	fi
	@cp $(UPDATEFILE).new $(INSTALLDIR)/$(UPDATEFILE)
	@cp $(UPDATEFILE) $(INSTALLDIR)/$(UNENCRYPTED_UPDATEFILE)
	@cp $(KERNEL_FILE).new $(INSTALLDIR)/$(KERNEL_FILE)
	@cp $(KERNEL_FILE) $(INSTALLDIR)/$(UNENCRYPTED_KERNEL_FILE)
	@cp $(BOOT_KERNEL_FILE).new $(INSTALLDIR)/$(BOOT_KERNEL_FILE)
	@cp $(BOOT_KERNEL_FILE) $(INSTALLDIR)/$(UNENCRYPTED_BOOT_KERNEL_FILE)
	@-rm $(UPDATEFILE)* $(KERNEL_FILE)* $(BOOT_KERNEL_FILE)*


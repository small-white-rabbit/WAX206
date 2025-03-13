include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=kswitch
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define KernelPackage/kswitch
	CATEGORY:=TW Properties
	SUBMENU:=TW kernel switch utilities
	TITLE:=TW kernel switc helper
	FILES:=$(PKG_BUILD_DIR)/kswitch.ko
	KCONFIG:=
	DEPENDS+= +TARGET_ramips:kmod-mediatek_hnat_ramips +TARGET_mediatek:kmod-mediatek_hnat
endef

define KernelPackage/kswitch/description
	TW kernel switch utilities
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./src/* $(PKG_BUILD_DIR)
	$(CP) ./files/*.ko $(PKG_BUILD_DIR)
	mkdir -p $(PKG_BUILD_DIR)/ipkg-aarch64_cortex-a53_neon-vfpv4/$(1)
	tar -zxvf files/data.tar.gz -C $(PKG_BUILD_DIR)/ipkg-aarch64_cortex-a53_neon-vfpv4/$(1)/
endef

define KernelPackage/kswitch/install
	tar -zxvf files/data.tar.gz -C $(1)/
endef

$(eval $(call KernelPackage,kswitch))

include $(TOPDIR)/rules.mk

PKG_NAME:=swop
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Package/swop
	SECTION:=TW Properties
	CATEGORY:=TW Properties
	TITLE:=TW Switch operation helper
	DEPENDS:=+dai +fwk +libnvram
	SUBMENU:=Applications
	MENU:=1
endef

define Package/swop/description
	TW Switch operation helper
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./src/* $(PKG_BUILD_DIR)
	$(CP) ./files/*.h $(PKG_BUILD_DIR)
	[ ./files/swop ] && $(CP) ./files/swop $(PKG_BUILD_DIR)
endef

define Package/swop/install
	tar -zxvf files/data.tar.gz -C $(1)/
endef

$(eval $(call BuildPackage,swop))

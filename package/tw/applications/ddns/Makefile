include $(TOPDIR)/rules.mk

PKG_NAME:=ddns
PKG_RELEASE:=1
PKG_VERSION:=2021-02-22

include $(INCLUDE_DIR)/package.mk

define Package/ddns
	SECTION:=TW Properties
	CATEGORY:=TW Properties
	TITLE:=Netgear ddns
	DEPENDS:=+ubus +ubox +fwk +dai +libopenssl
	SUBMENU:=Applications
	MENU:=1
endef

define Package/ddns/description
	This package is a demonstration of generate-package
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./src/* $(PKG_BUILD_DIR)
	$(CP) ./files/*.h $(PKG_BUILD_DIR)
	[ ./files/ddns ] && $(CP) ./files/ddns $(PKG_BUILD_DIR)
endef

define Package/ddns/install
	tar -zxvf files/data.tar.gz -C $(1)/
endef

$(eval $(call BuildPackage,ddns))

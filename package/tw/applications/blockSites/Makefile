include $(TOPDIR)/rules.mk

PKG_NAME:=blockSites
PKG_RELEASE:=1
PKG_VERSION:=2021-03-25

include $(INCLUDE_DIR)/package.mk

define Package/blockSites
	SECTION:=TW Properties
	CATEGORY:=TW Properties
	TITLE:=HTTP block Sites manage
	DEPENDS:=+libubus +libubox +fwk +dai +libjson-c
	SUBMENU:=Applications
	MENU:=1
endef

define Package/blockSites/description
	This package is for HTTP block Sites manage
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./src/* $(PKG_BUILD_DIR)
	$(CP) ./files/*.h $(PKG_BUILD_DIR)
	[ ./files/blockSites ] && $(CP) ./files/blockSites $(PKG_BUILD_DIR)
endef

define Package/blockSites/install
	tar -zxvf files/data.tar.gz -C $(1)/
endef

$(eval $(call BuildPackage,blockSites))

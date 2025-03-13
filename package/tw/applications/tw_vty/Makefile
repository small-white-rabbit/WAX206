include $(TOPDIR)/rules.mk

PKG_NAME:=tw_vty
PKG_RELEASE:=1
PKG_VERSION:=2020-04-16

include $(INCLUDE_DIR)/package.mk

define Package/tw_vty
	SECTION:=TW Properties
	CATEGORY:=TW Properties
	TITLE:=tw_vty for debugging
	DEPENDS:=+libubus +libubox +libuci +dai +libreadline +libncurses +fwk +TARGET_mediatek:libswitch +TARGET_mediatek:mii_mgr
	SUBMENU:=Applications
endef

define Package/tw_vty/description
	This package is a demonstration of generate-package
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./src/* $(PKG_BUILD_DIR)
	$(CP) ./files/*.h $(PKG_BUILD_DIR)
	[ ./files/tw_vty ] && $(CP) ./files/tw_vty $(PKG_BUILD_DIR)
endef

define Package/tw_vty/install
	tar -zxvf files/data.tar.gz -C $(1)/
endef

$(eval $(call BuildPackage,tw_vty))

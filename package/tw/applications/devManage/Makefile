include $(TOPDIR)/rules.mk

PKG_NAME:=devManage
PKG_RELEASE:=1
PKG_VERSION:=2021-01-25

include $(INCLUDE_DIR)/package.mk

define Package/devManage
	SECTION:=TW Properties
	CATEGORY:=TW Properties
	TITLE:=attach device manage
	DEPENDS:=+libubus +libubox +fwk +dai +libjson-c
	SUBMENU:=Applications
	MENU:=1
endef

define Package/devManage/description
	This package is for attach devices manage
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./src/* $(PKG_BUILD_DIR)
	$(CP) ./files/*.h $(PKG_BUILD_DIR)
	[ ./files/devManage ] && $(CP) ./files/devManage $(PKG_BUILD_DIR)
endef

define Package/devManage/install
	tar -zxvf files/data.tar.gz -C $(1)/
endef

$(eval $(call BuildPackage,devManage))

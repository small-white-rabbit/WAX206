include $(TOPDIR)/rules.mk

PKG_NAME:=autoDetect
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Package/autoDetect
	SECTION:=TW Properties
	CATEGORY:=TW Properties
	TITLE:=IPv6 internet connection type auto detection
	DEPENDS:=+libubus +libubox +uci +fwk +dai
	SUBMENU:=Applications
	MENU:=1
endef

define Package/autoDetect/description
	IPv6 internet connection type auto detection
endef

define Package/$(PKG_NAME)/extra_provides
	echo "libblobmsg_json.so"; echo "libfwk.so"; echo "libc.so.6";
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./src/* $(PKG_BUILD_DIR)
	$(CP) ./files/*.h $(PKG_BUILD_DIR)
	[ ./files/autoDetect ] && $(CP) ./files/autoDetect $(PKG_BUILD_DIR)
endef

define Package/autoDetect/install
	tar -zxvf files/data.tar.gz -C $(1)/
endef

$(eval $(call BuildPackage,autoDetect))

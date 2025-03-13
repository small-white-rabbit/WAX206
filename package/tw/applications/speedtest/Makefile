include $(TOPDIR)/rules.mk

PKG_NAME:=speedtest
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Package/speedtest
	SECTION:=TW Properties
	CATEGORY:=TW Properties
	TITLE:=speedtest
	DEPENDS:=+ookla +dai +fwk +libjson-c
endef

define Package/speedtest/description
	speedtest
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./src/* $(PKG_BUILD_DIR)
	[ ./files/speedtest ] && $(CP) ./files/speedtest $(PKG_BUILD_DIR)
endef

define Package/speedtest/install
	tar -zxvf files/data.tar.gz -C $(1)/
endef

$(eval $(call BuildPackage,speedtest))

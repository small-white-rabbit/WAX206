include $(TOPDIR)/rules.mk

PKG_NAME:=trafficMeter
PKG_RELEASE:=1
PKG_VERSION:=2021-05-20

include $(INCLUDE_DIR)/package.mk

define Package/trafficMeter
	SECTION:=TW Properties
	CATEGORY:=TW Properties
	TITLE:=Netgear POT
	DEPENDS:=+ubus +ubox +fwk +dai
	SUBMENU:=Applications
	MENU:=1
endef

define Package/trafficMeter/description
	This package is a demonstration of generate-package
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./src/* $(PKG_BUILD_DIR)
	[ ./files/trafficMeter ] && $(CP) ./files/trafficMeter $(PKG_BUILD_DIR)
endef

define Package/trafficMeter/install
	tar -zxvf files/data.tar.gz -C $(1)/
endef

$(eval $(call BuildPackage,trafficMeter))

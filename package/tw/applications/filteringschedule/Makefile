include $(TOPDIR)/rules.mk

PKG_NAME:=filteringschedule
PKG_RELEASE:=1
PKG_VERSION:=1

include $(INCLUDE_DIR)/package.mk

define Package/filteringschedule
	SUBMENU:=Applications
	TITLE:=Turns Block on and off according to a schedule
	SECTION:=TW Properties
	CATEGORY:=TW Properties
endef

define Package/filteringschedule/description
	Turns Block on and off according to a schedule defined in UCI.
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./src/* $(PKG_BUILD_DIR)
endef

define Package/filteringschedule/install
	tar -zxvf files/data.tar.gz -C $(1)/
endef

$(eval $(call BuildPackage,filteringschedule))

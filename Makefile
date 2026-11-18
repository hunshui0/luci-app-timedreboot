# [K] (C)2020
# http://github.com/kongfl888

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-timedreboot
PKG_VERSION:=1.1
PKG_RELEASE:=3
PKG_DATE:=20220920
PKG_BUILD_DEPENDS:=luci-base/host

PKG_MAINTAINER:=kongfl888 <kongfl888@outlook.com>
PKG_LICENSE:=GPL-3.0

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
  CATEGORY:=LuCI
  SUBMENU:=3. Applications
  TITLE:=LuCI Application to timing reboot.
  PKGARCH:=all
  DEPENDS:=+luci-compat +bash
endef

define Package/$(PKG_NAME)/description
	LuCI Application to timing reboot
endef

define Package/$(PKG_NAME)/conffiles
/etc/config/timedreboot
endef

define Build/Compile
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./root/etc/config/timedreboot $(1)/etc/config/timedreboot
	$(INSTALL_DIR) $(1)/lib/upgrade/keep.d
	$(INSTALL_DATA) ./root/lib/upgrade/keep.d/luci-app-timedreboot $(1)/lib/upgrade/keep.d/

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./root/etc/init.d/timedreboot $(1)/etc/init.d/timedreboot

	$(INSTALL_DIR) $(1)/usr/bin $(1)/usr/share
	$(INSTALL_BIN) ./root/usr/bin/dorboot $(1)/usr/bin/dorboot
	$(CP) ./root/usr/share/. $(1)/usr/share/

	$(INSTALL_DIR) $(1)/usr/lib/lua/luci
	cp -pR ./luasrc/* $(1)/usr/lib/lua/luci/

	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/i18n
	$(STAGING_DIR_HOSTPKG)/bin/po2lmo ./po/zh-cn/timedreboot.po $(1)/usr/lib/lua/luci/i18n/timedreboot.zh-cn.lmo
endef

define Package/$(PKG_NAME)/postinst
#!/bin/sh
    model="${IPKG_INSTROOT}/usr/lib/lua/luci/model/cbi/timedreboot.lua"
    if ! grep -Fq 'option(MultiValue, "week"' "$model"; then
        echo "timedreboot: the weekday form was not installed at $model" >&2
        exit 1
    fi
    if [ ! -s "${IPKG_INSTROOT}/usr/lib/lua/luci/view/timedreboot/weekdays.htm" ]; then
        echo "timedreboot: the weekday dropdown template is missing" >&2
        exit 1
    fi
    if [ -z "${IPKG_INSTROOT}" ]; then
        rm -f /tmp/luci-indexcache /tmp/luci-indexcache.*.json
        rm -rf /tmp/luci-modulecache
    fi
endef

define Package/$(PKG_NAME)/postrm
#!/bin/sh
    sed -i '/dorboot/d' /etc/crontabs/root >/dev/null 2>&1 || echo ""
    rm -rf /tmp/luci-modulecache/ >/dev/null 2>&1 || echo ""
    rm -f /tmp/luci-indexcache >/dev/null 2>&1 || echo ""
    exit 0
endef

$(eval $(call BuildPackage,$(PKG_NAME)))


#
# Unisoc UWE5622 SDIO Wi-Fi (Orange Pi Zero2/Zero3), Armbian-maintained driver.
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=uwe5622
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/armbian/uwe5622.git
PKG_SOURCE_DATE:=2026-10-13
PKG_SOURCE_VERSION:=fa9d1a6703a93a85bcf68e865ebc2726474076ad
# Pin after the first download: make package/uwe5622/check FIXUP=1
PKG_MIRROR_HASH:=e65b3b788b15aef395d13bd1076b76ce476855b2b26fa28fef470943df8ab73d

PKG_LICENSE:=GPL-2.0-only
PKG_BUILD_PARALLEL:=1
PKG_FLAGS:=nonshared

STAMP_CONFIGURED_DEPENDS := $(STAGING_DIR)/usr/include/mac80211-backport/backport/autoconf.h

include $(INCLUDE_DIR)/package.mk

# Firmware: Armbian firmware repo, pinned commit. wcnmodem.bin is
# MARLIN3_19B_W21.05.3 (sc2355 marlin3 lite), the image Armbian ships for
# Orange Pi Zero2/Zero3.
UWE5622_FW_COMMIT:=f7fa5956ecca08af42991633a4a8f09d3b1926e5
UWE5622_FW_URL:=https://raw.githubusercontent.com/armbian/firmware/$(UWE5622_FW_COMMIT)/uwe5622/
UWE5622_FW_SHORT:=f7fa5956
UWE5622_FW_BIN:=uwe5622-wcnmodem-$(UWE5622_FW_SHORT).bin
UWE5622_FW_INI:=uwe5622-wifi_2355b001_1ant-$(UWE5622_FW_SHORT).ini

define Download/uwe5622-wcnmodem
  URL:=$(UWE5622_FW_URL)
  URL_FILE:=wcnmodem.bin
  FILE:=$(UWE5622_FW_BIN)
  HASH:=119b87ce30875734a67462f7293fb8fe85acf3270fe8b78c978ae24be7715a80
endef
$(eval $(call Download,uwe5622-wcnmodem))

define Download/uwe5622-wifi-ini
  URL:=$(UWE5622_FW_URL)
  URL_FILE:=wifi_2355b001_1ant.ini
  FILE:=$(UWE5622_FW_INI)
  HASH:=1f3c40ec245a8d0b99ad1c23706597d6dd5008ab80cefb7bcc1956efc4e938f7
endef
$(eval $(call Download,uwe5622-wifi-ini))

# OpenWrt builds cfg80211 from mac80211 backports, whose API can be newer
# than the kernel (e.g. backports 7.2 on Linux 6.18). The driver's cfg80211
# op signatures must follow the backports version, not LINUX_VERSION_CODE.
MAC80211_SRC_VERSION:=$(shell sed -n 's/^PKG_SOURCE_VERSION:=//p' $(TOPDIR)/package/kernel/mac80211/Makefile)
MAC80211_VER_WORDS:=$(subst ., ,$(firstword $(subst -, ,$(MAC80211_SRC_VERSION))))
ifeq ($(word 2,$(MAC80211_VER_WORDS)),)
  $(error uwe5622: cannot parse mac80211 backports version '$(MAC80211_SRC_VERSION)')
endif
UWE5622_CFG80211_API:=$(shell printf '0x%02x%02x00' $(word 1,$(MAC80211_VER_WORDS)) $(word 2,$(MAC80211_VER_WORDS)))

NOSTDINC_FLAGS := \
	$(KERNEL_NOSTDINC_FLAGS) \
	-I$(STAGING_DIR)/usr/include/mac80211-backport/uapi \
	-I$(STAGING_DIR)/usr/include/mac80211-backport \
	-I$(STAGING_DIR)/usr/include/mac80211/uapi \
	-I$(STAGING_DIR)/usr/include/mac80211 \
	-include backport/autoconf.h \
	-include backport/backport.h \
	-DSPRDWL_CFG80211_VERSION=$(UWE5622_CFG80211_API)

define KernelPackage/uwe5622
  SUBMENU:=Wireless Drivers
  TITLE:=Unisoc UWE5622 SDIO Wi-Fi (Orange Pi Zero2/Zero3)
  URL:=https://github.com/armbian/uwe5622
  DEPENDS:=@TARGET_sunxi +kmod-cfg80211 +uwe5622-firmware
  FILES:= \
	$(PKG_BUILD_DIR)/unisocwcn/uwe5622_bsp_sdio.ko \
	$(PKG_BUILD_DIR)/unisocwifi/sprdwl_ng.ko
  AUTOLOAD:=$(call AutoProbe,uwe5622_bsp_sdio sprdwl_ng)
endef

define KernelPackage/uwe5622/description
 Armbian-maintained driver for the Unisoc UWE5622 Wi-Fi module on SDIO
 (Orange Pi Zero2/Zero3). Wi-Fi only; the Bluetooth tty-sdio module is
 not built.
endef

define Package/uwe5622-firmware
  SECTION:=firmware
  CATEGORY:=Firmware
  TITLE:=Unisoc UWE5622 Wi-Fi firmware and RF config
  URL:=https://github.com/armbian/firmware/tree/$(UWE5622_FW_COMMIT)/uwe5622
  DEPENDS:=@TARGET_sunxi
endef

define Package/uwe5622-firmware/description
 wcnmodem.bin and wifi_2355b001_1ant.ini for the UWE5622, from the Armbian
 firmware repository.
endef

define Build/Compile
	+$(KERNEL_MAKE) $(PKG_JOBS) \
		M="$(PKG_BUILD_DIR)" \
		NOSTDINC_FLAGS="$(NOSTDINC_FLAGS)" \
		CONFIG_AW_WIFI_DEVICE_UWE5622=y \
		CONFIG_WLAN_UWE5622=m \
		modules
endef

define Package/uwe5622-firmware/install
	$(INSTALL_DIR) $(1)/lib/firmware/uwe5622
	$(INSTALL_DATA) $(DL_DIR)/$(UWE5622_FW_BIN) $(1)/lib/firmware/uwe5622/wcnmodem.bin
	$(INSTALL_DATA) $(DL_DIR)/$(UWE5622_FW_INI) $(1)/lib/firmware/uwe5622/wifi_2355b001_1ant.ini
	$(LN) uwe5622/wcnmodem.bin $(1)/lib/firmware/wcnmodem.bin
	$(LN) uwe5622/wifi_2355b001_1ant.ini $(1)/lib/firmware/wifi_2355b001_1ant.ini
endef

$(eval $(call KernelPackage,uwe5622))
$(eval $(call BuildPackage,uwe5622-firmware))

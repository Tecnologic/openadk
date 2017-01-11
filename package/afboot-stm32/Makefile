# This file is part of the OpenADK project. OpenADK is copyrighted
# material, please see the LICENCE file in the top-level directory.

include $(ADK_TOPDIR)/rules.mk

PKG_NAME:=		afboot-stm32
PKG_VERSION:=		8e9e03159ce47629d40dbed4c50c1879b69bb197
PKG_RELEASE:=		1
PKG_DESCR:=		bootloader for stm32 devices
PKG_SECTION:=		base/boot
PKG_SITES:=		https://github.com/mcoquelin-stm32/afboot-stm32.git

PKG_SYSTEM_DEPENDS:=	st-stm32f429 st-stm32f769

include $(ADK_TOPDIR)/mk/package.mk

$(eval $(call PKG_template,AFBOOT_STM32,afboot-stm32,$(PKG_VERSION)-$(PKG_RELEASE),$(PKG_DEPENDS),$(PKG_DESCR),$(PKG_SECTION)))

CONFIG_STYLE:=		manual
INSTALL_STYLE:=		manual

afboot-stm32-install:
	$(CP) $(WRKBUILD)/stm32746g-eval.bin $(FW_DIR)

include $(ADK_TOPDIR)/mk/pkg-bottom.mk

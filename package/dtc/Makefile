# This file is part of the OpenADK project. OpenADK is copyrighted
# material, please see the LICENCE file in the top-level directory.

include $(ADK_TOPDIR)/rules.mk

PKG_NAME:=		dtc
PKG_VERSION:=		1.4.2
PKG_RELEASE:=		1
PKG_HASH:=		4c1f9e55106c5111de091beba04d5ab89d6e52f185684fca0944d3b62ce5f084
PKG_DESCR:=		compiler for dts files
PKG_SECTION:=		sys/misc
HOST_BUILDDEP:=		m4-host flex-host bison-host
PKG_URL:=		http://www.devicetree.org/Device_Tree_Compiler
PKG_SITES:=		https://github.com/dgibson/dtc/archive/

DISTFILES:=		v$(PKG_VERSION).tar.gz

PKG_CFLINE_DTC:=	depends on ADK_HOST_ONLY

include $(ADK_TOPDIR)/mk/host.mk
include $(ADK_TOPDIR)/mk/package.mk

$(eval $(call HOST_template,DTC,dtc,$(PKG_VERSION)-$(PKG_RELEASE)))

HOST_STYLE:=		manual

host-build:
	(cd ${WRKBUILD} && env ${HOST_MAKE_ENV} ${MAKE} -f ${MAKE_FILE} \
		${HOST_MAKE_FLAGS} dtc)

dtc-hostinstall:
	$(INSTALL_DIR) $(STAGING_HOST_DIR)/usr/bin
	$(INSTALL_BIN) $(WRKBUILD)/dtc $(STAGING_HOST_DIR)/usr/bin

include $(ADK_TOPDIR)/mk/host-bottom.mk
include $(ADK_TOPDIR)/mk/pkg-bottom.mk

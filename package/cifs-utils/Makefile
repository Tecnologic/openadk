# This file is part of the OpenADK project. OpenADK is copyrighted
# material, please see the LICENCE file in the top-level directory.

include $(ADK_TOPDIR)/rules.mk

PKG_NAME:=		cifs-utils
PKG_VERSION:=		6.6
PKG_RELEASE:=		1
PKG_HASH:=		d07152a807de6840566bbcc69a97ff6fa17fca4e09ceb4641d74882a83e67125
PKG_DESCR:=		network filesystem utilities
PKG_SECTION:=		net/fs
PKG_KDEPENDS:=		cifs
PKG_URL:=		https://wiki.samba.org/index.php/LinuxCIFS_utils
PKG_SITES:=		https://ftp.samba.org/pub/linux-cifs/cifs-utils/

DISTFILES:=             ${PKG_NAME}-${PKG_VERSION}.tar.bz2

include $(ADK_TOPDIR)/mk/package.mk

$(eval $(call PKG_template,CIFS_UTILS,cifs-utils,$(PKG_VERSION)-${PKG_RELEASE},${PKG_DEPENDS},${PKG_DESCR},${PKG_SECTION}))

AUTOTOOL_STYLE:=	autoreconf
CONFIGURE_ARGS+=	--disable-cifsupcall \
			--disable-cifsidmap \
			--disable-cifsacl \
			--disable-pam \
			--disable-pie \
			--without-libcap \
			--disable-systemd

cifs-utils-install:
	$(INSTALL_DIR) $(IDIR_CIFS_UTILS)/sbin
	$(INSTALL_BIN) $(WRKINST)/sbin/mount.cifs \
		$(IDIR_CIFS_UTILS)/sbin

include ${ADK_TOPDIR}/mk/pkg-bottom.mk

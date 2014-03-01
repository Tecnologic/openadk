# This file is part of the OpenADK project. OpenADK is copyrighted
# material, please see the LICENCE file in the top-level directory.

TOPDIR=$(shell pwd)
export TOPDIR

ifneq ($(shell umask 2>/dev/null | sed 's/0*022/OK/'),OK)
$(error your umask is not 022)
endif

CONFIG_CONFIG_IN = Config.in
CONFIG = config
DEFCONFIG=		ADK_DEBUG=n \
			ADK_STATIC=n \
			ADK_WGET_TIMEOUT=180 \
			ADK_MAKE_PARALLEL=y \
			ADK_MAKE_JOBS=4 \
			ADK_LEAVE_ETC_ALONE=n \
			ADK_SIMPLE_NETWORK_CONFIG=n \
			ADK_USE_CCACHE=n \
			ADK_PACKAGE_BASE_FILES=y \
			ADK_PACKAGE_E2FSCK_STATIC=n \
			ADK_PACKAGE_KEXECINIT=n \
			ADK_PACKAGE_INSTALLER=n \
			ADK_PACKAGE_LM_SENSORS_DETECT=n \
			ADK_PACKAGE_PACEMAKER=n \
			ADK_PACKAGE_PACEMAKER_MGMTD=n \
			ADK_PACKAGE_PACEMAKER_PYTHON_GUI=n \
			ADK_PACKAGE_CLASSPATH=n \
			ADK_PACKAGE_GRUB=n \
			ADK_PACKAGE_U_BOOT=n \
			ADK_PACKAGE_CRYPTINIT=n \
			ADK_PACKAGE_PAM=n \
			ADK_PACKAGE_VIRTINST=n \
			ADK_PACKAGE_URLGRABBER=n \
			ADK_PACKAGE_LIBSSP=n \
			ADK_PACKAGE_OPENAFS=n \
			ADK_PACKAGE_OPENJDK7=n \
			ADK_PKG_XORG=n \
			ADK_PKG_MPDBOX=n \
			ADK_PKG_DEVELOPMENT=n \
			ADK_TOOLCHAIN_GCC_USE_SSP=n \
			ADK_TOOLCHAIN_GCC_USE_LTO=n \
			BUSYBOX_IFPLUGD=n \
			BUSYBOX_EXTRA_COMPAT=n \
			BUSYBOX_FEATURE_IFCONFIG_SLIP=n \
			BUSYBOX_BBCONFIG=n \
			BUSYBOX_SELINUX=n \
			BUSYBOX_INSTALL_NO_USR=n \
			BUSYBOX_MODPROBE_SMALL=n \
			BUSYBOX_EJECT=n \
			BUSYBOX_UBIDETACH=n \
			BUSYBOX_UBIATTACH=n \
			BUSYBOX_BUILD_LIBBUSYBOX=n \
			BUSYBOX_FEATURE_2_4_MODULES=n \
			BUSYBOX_LOCALE_SUPPORT=n \
			BUSYBOX_FEATURE_PREFER_APPLETS=n \
			BUSYBOX_FEATURE_SUID=n \
			BUSYBOX_SELINUXENABLED=n \
			BUSYBOX_FEATURE_INSTALLER=n \
			BUSYBOX_PAM=n \
			BUSYBOX_FLASH_LOCK=n \
			BUSYBOX_FLASH_UNLOCK=n \
			BUSYBOX_FLASH_ERASEALL=n \
			BUSYBOX_PIE=n \
			BUSYBOX_TASKSET=n \
			BUSYBOX_DEBUG=n \
			BUSYBOX_NOMMU=n \
			BUSYBOX_WERROR=n \
			BUSYBOX_STATIC=n \
			BUSYBOX_FEATURE_AIX_LABEL=n \
			BUSYBOX_FEATURE_SUN_LABEL=n \
			BUSYBOX_FEATURE_OSF_LABEL=n \
			BUSYBOX_FEATURE_SGI_LABEL=n \
			BUSYBOX_FEATURE_INETD_RPC=n \
			BUSYBOX_FEATURE_MOUNT_NFS=n \
			BUSYBOX_FEATURE_VI_REGEX_SEARCH=n \
			ADK_KERNEL_RT2X00_DEBUG=n \
			ADK_KERNEL_ATH5K_DEBUG=n \
			ADK_KERNEL_DEBUG_WITH_KGDB=n

noconfig_targets:=	menuconfig \
			guiconfig \
			_config \
			_mconfig \
			distclean \
			defconfig \
			tags

POSTCONFIG=		-@\
	if [ -f .adkinit ];then rm .adkinit;\
	else \
	if [ -f .config.old ];then \
		$(TOPDIR)/host_$(GNU_HOST_NAME)/usr/bin/pkgrebuild;\
		rebuild=0; \
		if [ "$$(grep ^BUSYBOX .config|md5sum)" != "$$(grep ^BUSYBOX .config.old|md5sum)" ];then \
			touch .rebuild.busybox;\
			rebuild=1;\
		fi; \
		for i in ADK_RUNTIME_PASSWORD ADK_RUNTIME_TMPFS_SIZE ADK_RUNTIME_HOSTNAME ADK_TARGET_ROOTFS ADK_RUNTIME_CONSOLE ADK_TARGET_QEMU_MICROBLAZE_MODEL;do \
			if [ "$$(grep ^$$i .config|md5sum)" != "$$(grep ^$$i .config.old|md5sum)" ];then \
				touch .rebuild.base-files;\
				rebuild=1;\
			fi; \
		done; \
		if [ "$$(grep ^ADK_RUNTIME_TIMEZONE .config|md5sum)" != "$$(grep ^ADK_RUNTIME_TIMEZONE .config.old|md5sum)" ];then \
			touch .rebuild.eglibc .rebuild.uclibc .rebuild.glibc;\
			rebuild=1;\
		fi; \
		if [ "$$(grep ^ADK_RUNTIME_SSH_PUBKEY .config|md5sum)" != "$$(grep ^ADK_RUNTIME_SSH_PUBKEY .config.old|md5sum)" ];then \
			touch .rebuild.dropbear .rebuild.openssh;\
			rebuild=1;\
		fi; \
		if [ "$$(grep ^ADK_RUNTIME_KBD_LAYOUT .config|md5sum)" != "$$(grep ^ADK_RUNTIME_KBD_LAYOUT .config.old|md5sum)" ];then \
			touch .rebuild.bkeymaps;\
			rebuild=1;\
		fi; \
		if [ "$$(grep ^ADK_KERNEL_VERSION_ .config|md5sum)" != "$$(grep ^ADK_KERNEL_VERSION_ .config.old|md5sum)" ];then \
			make kernelclean;\
		fi; \
		if [ "$$(grep ^ADK_LINUX_ARM_WITH_THUMB .config|md5sum)" != "$$(grep ^ADK_LINUX_ARM_WITH_THUMB .config.old|md5sum)" ];then \
			echo "You should make cleantarget, after changing thumb mode";\
		fi; \
		if [ $$rebuild -eq 1 ];then \
			cp .config .config.old;\
		fi; \
	fi; \
	fi

# Pull in the user's configuration file
ifeq ($(filter $(noconfig_targets),$(MAKECMDGOALS)),)
-include $(TOPDIR)/.config
endif

ifeq ($(strip $(ADK_HAVE_DOT_CONFIG)),y)
include $(TOPDIR)/rules.mk

all: world

${TOPDIR}/package/Depends.mk: ${TOPDIR}/.config $(wildcard ${TOPDIR}/package/*/Makefile)
	$(STAGING_HOST_DIR)/usr/bin/depmaker > ${TOPDIR}/package/Depends.mk

.NOTPARALLEL:
.PHONY: all world clean cleantarget cleandir distclean image_clean

world:
	mkdir -p $(DISTDIR) $(BUILD_DIR) $(TARGET_DIR) $(FW_DIR) \
		$(PACKAGE_DIR) $(BIN_DIR) $(TOOLS_BUILD_DIR) \
		$(TOOLCHAIN_BUILD_DIR) $(STAGING_PKG_DIR)/stamps
	${BASH} ${TOPDIR}/scripts/scan-pkgs.sh
	${BASH} ${TOPDIR}/scripts/update-sys
	${BASH} ${TOPDIR}/scripts/update-pkg
ifeq ($(ADK_NATIVE),y)
	$(MAKE) -f mk/build.mk toolchain/kernel-headers-prepare tools/install target/config-prepare target/compile package/compile root_clean package/install package_index target/install
else
ifeq ($(ADK_TOOLCHAIN),y)
ifeq ($(ADK_TOOLCHAIN_ONLY),y)
	$(MAKE) -f mk/build.mk tools/install toolchain/fixup package/compile
else
	$(MAKE) -f mk/build.mk tools/install toolchain/fixup package/compile root_clean package/install
endif
else
	$(MAKE) -f mk/build.mk tools/install toolchain/fixup target/config-prepare target/compile package/compile root_clean package/install target/install package_index
endif
endif

package_index:
ifeq ($(ADK_TARGET_PACKAGE_IPKG),y)
	-cd ${PACKAGE_DIR} && \
	    ${BASH} ${TOPDIR}/scripts/ipkg-make-index.sh . >Packages
endif

${STAGING_DIR} ${STAGING_DIR}/etc ${STAGING_HOST_DIR}:
	mkdir -p ${STAGING_DIR}/{bin,etc,lib,usr/bin,usr/include,usr/lib/pkgconfig} \
		${STAGING_HOST_DIR}/{bin,lib,usr/bin,usr/lib,usr/include}

${STAGING_DIR}/etc/ipkg.conf: ${STAGING_DIR}/etc
ifeq ($(ADK_TARGET_PACKAGE_IPKG),y)
	echo "dest root /" >${STAGING_DIR}/etc/ipkg.conf
	echo "option offline_root ${TARGET_DIR}" >>$(STAGING_DIR)/etc/ipkg.conf
endif

package/%: ${STAGING_DIR}/etc/ipkg.conf ${TOPDIR}/package/Depends.mk
	$(MAKE) -C package $(patsubst package/%,%,$@)

target/%:
	$(MAKE) -C target $(patsubst target/%,%,$@)

toolchain/%: ${STAGING_DIR}
	$(MAKE) -C toolchain $(patsubst toolchain/%,%,$@)

tools/%:
	$(MAKE) -C tools $(patsubst tools/%,%,$@)

image:
	$(MAKE) -C target image

switch:
	if [ -f .config ];then \
		echo "Saving configuration for target system: ${ADK_TARGET_SYSTEM} with arch: ${ADK_TARGET_ARCH}";\
		cp -p .config .config.${ADK_TARGET_ARCH}_${ADK_TARGET_SYSTEM};\
	fi
	if [ -f .config.old ];then cp -p .config.old .config.old.${ADK_TARGET_ARCH}_${ADK_TARGET_SYSTEM};fi
	if [ -f .config.${ARCH}_${SYSTEM} ];then \
		cp -p .config.${ARCH}_${SYSTEM} .config; \
		cp -p .config.old.${ARCH}_${SYSTEM} .config.old; \
		$(MAKE) dep; rm .rebuild.* 2>/dev/null ; \
		echo "Setting configuration to target system: ${SYSTEM} with arch: ${ARCH}"; \
	else \
		echo "No old target config found" ;\
		mv .config .config.bak ; mv .config.old .config.old.bak; rm .rebuild.* 2>/dev/null ; \
		if [ ! -z "$(SYSTEM)" ];then \
			make ARCH=${ARCH} SYSTEM=${SYSTEM} menuconfig; \
		else \
			make menuconfig; \
		fi \
	fi

ifeq (${ADK_TARGET_KERNEL64},y)
KERNEL_CFG:=kernel64.config
else
KERNEL_CFG:=kernel.config
endif

kernelconfig:
	cp $(TOPDIR)/target/$(ADK_TARGET_ARCH)/${KERNEL_CFG} $(BUILD_DIR)/linux/.config
	${KERNEL_MAKE_ENV} ${MAKE} ARCH=$(ARCH) ${KERNEL_MAKE_OPTS} -C $(BUILD_DIR)/linux menuconfig
	cp $(BUILD_DIR)/linux/.config $(TOPDIR)/target/$(ADK_TARGET_ARCH)/${KERNEL_CFG}

# create a new package from package/.template
newpackage:
	@echo "Creating new package $(PKG)"
	$(CP) $(TOPDIR)/package/.template$(TYPE) $(TOPDIR)/package/$(PKG)
	pkg=$$(echo $(PKG)|tr '[:lower:]-' '[:upper:]_'); \
		$(SED) "s#@UPKG@#$$pkg#" $(TOPDIR)/package/$(PKG)/Makefile
	$(SED) 's#@PKG@#$(PKG)#' $(TOPDIR)/package/$(PKG)/Makefile
	$(SED) 's#@VER@#$(VER)#' $(TOPDIR)/package/$(PKG)/Makefile
	@echo "Edit package/$(PKG)/Makefile to complete"

root_clean:
	@$(TRACE) root_clean
	rm -rf $(TARGET_DIR)
	mkdir -p $(TARGET_DIR)

# Do a per-package clean here, too. This way stale headers and
# libraries from target_*/ get wiped away, which keeps
# future package build's configure scripts from returning false
# dependencies information.

clean:
	@$(TRACE) clean
	$(MAKE) -C $(CONFIG) clean
	for f in $$(ls ${STAGING_PKG_DIR}/ 2>/dev/null |grep -v [A-Z]|grep -v stamps 2>/dev/null); do  \
		while read file ; do \
			echo ${STAGING_DIR}/$$file ;\
			rm ${STAGING_DIR}/$$file 2>/dev/null;\
		done < $$f ; \
		echo ${STAGING_PKG_DIR}/$$f ;\
		rm ${STAGING_PKG_DIR}/$$f ; \
	done
	rm -rf $(BUILD_DIR) $(FW_DIR) $(TARGET_DIR) \
	    	${TOPDIR}/package/pkglist.d
	rm -f ${TOPDIR}/package/Depends.mk

cleankernel:
	@$(TRACE) cleankernel
	rm -rf $(TOOLCHAIN_BUILD_DIR)/w-linux* $(BUILD_DIR)/linux

cleandir:
	@$(TRACE) cleandir
	@$(MAKE) -C $(CONFIG) clean $(MAKE_TRACE) 
	rm -rf $(BUILD_DIR_PFX) $(FW_DIR_PFX) $(TARGET_DIR_PFX) \
	    ${TOPDIR}/package/pkglist.d ${TOPDIR}/package/pkgconfigs.d
	rm -rf $(TOOLCHAIN_BUILD_DIR_PFX) $(STAGING_HOST_DIR_PFX) $(TOOLS_BUILD_DIR)
	rm -rf $(STAGING_TARGET_DIR_PFX) $(STAGING_PKG_DIR_PFX)
	rm -f .menu .tmpconfig.h .rebuild* ${TOPDIR}/package/Depends.mk ${TOPDIR}/prereq.mk

cleantarget:
	@$(TRACE) cleantarget
	@$(MAKE) -C $(CONFIG) clean $(MAKE_TRACE)
	rm -rf $(BUILD_DIR) $(FW_DIR) $(TARGET_DIR)
	rm -rf $(TOOLCHAIN_BUILD_DIR) $(STAGING_HOST_DIR) $(STAGING_DIR) $(STAGING_PKG_DIR)
	rm -f .tmpconfig.h all.config .defconfig

distclean:
	@$(TRACE) distclean
	@$(MAKE) -C $(CONFIG) clean $(MAKE_TRACE)
	@rm -rf $(BUILD_DIR_PFX) $(FW_DIR_PFX) $(TARGET_DIR_PFX) $(DISTDIR) \
	    ${TOPDIR}/package/pkglist.d ${TOPDIR}/package/pkgconfigs.d
	@rm -rf $(TOOLCHAIN_BUILD_DIR_PFX) $(STAGING_HOST_DIR_PFX) $(TOOLS_BUILD_DIR)
	@rm -rf $(STAGING_TARGET_DIR_PFX) $(STAGING_PKG_DIR_PFX)
	@rm -f .adkinit .config* .defconfig .tmpconfig.h all.config ${TOPDIR}/prereq.mk \
	    .menu ${TOPDIR}/package/Depends.mk .ADK_HAVE_DOT_CONFIG .rebuild.*

else # ! ifeq ($(strip $(ADK_HAVE_DOT_CONFIG)),y)

ifeq ($(filter-out distclean,${MAKECMDGOALS}),)
include ${TOPDIR}/mk/vars.mk
else
include $(TOPDIR)/prereq.mk
export BASH MAKE LANGUAGE LC_ALL OStype PATH CC_FOR_BUILD QEMU SHELL
endif

all: menuconfig
	@echo "Start the build with \"make\" or with \"make v\" to be verbose"

# configuration
# ---------------------------------------------------------------------------

# force entering the subdir, as dependency checking is done there
.PHONY: $(CONFIG)/conf $(CONFIG)/mconf $(CONFIG)/gconf

$(CONFIG)/conf:
	@$(MAKE) -C $(CONFIG) conf

$(CONFIG)/mconf:
	@$(MAKE) -C $(CONFIG)

$(CONFIG)/gconf:
	@$(MAKE) -C $(CONFIG) gconf

defconfig: .menu $(CONFIG)/conf
	@${BASH} ${TOPDIR}/scripts/update-sys
	@${BASH} ${TOPDIR}/scripts/update-pkg
ifeq (${OStype},Linux)
	@echo ADK_HOST_LINUX=y > $(TOPDIR)/.defconfig
endif
ifeq (${OStype},FreeBSD)
	@echo ADK_HOST_FREEBSD=y > $(TOPDIR)/.defconfig
endif
ifeq (${OStype},MirBSD)
	@echo ADK_HOST_MIRBSD=y > $(TOPDIR)/.defconfig
endif
ifeq (${OStype},OpenBSD)
	@echo ADK_HOST_OPENBSD=y > $(TOPDIR)/.defconfig
endif
ifeq (${OStype},NetBSD)
	@echo ADK_HOST_NETBSD=y > $(TOPDIR)/.defconfig
endif
ifeq (${OStype},Darwin)
	@echo ADK_HOST_DARWIN=y > $(TOPDIR)/.defconfig
endif
ifneq (,$(filter CYGWIN%,${OStype}))
	@echo ADK_HOST_CYGWIN=y > $(TOPDIR)/.defconfig
endif
ifeq ($(ADKtype),ibm-x40)
	@echo ADK_LINUX_NATIVE=y >> $(TOPDIR)/.defconfig
	@echo ADK_TARGET_SYSTEM_IBM_X40=y >> $(TOPDIR)/.defconfig
	@sed -e "s#config ADK_TARGET#config ADK_NATIVE#" target/$(ARCH_FOR_BUILD)/sys-available/$(ADKtype) > \
		target/$(ARCH_FOR_BUILD)/sys-enabled/.$(ADKtype)
	@echo "choice" > $(TOPDIR)/target/config/Config.in.native
	@echo "prompt \"Target system (autodetected)\"" >> $(TOPDIR)/target/config/Config.in.native
	@echo "source \"target/$(ARCH_FOR_BUILD)/sys-enabled/.$(ADKtype)\"" >> $(TOPDIR)/target/config/Config.in.native
	@echo "endchoice" >> $(TOPDIR)/target/config/Config.in.native
endif
ifeq ($(ADKtype),lemote-yeelong)
	@echo ADK_LINUX_NATIVE=y >> $(TOPDIR)/.defconfig
	@echo ADK_TARGET_SYSTEM_LEMOTE_YEELONG=y >> $(TOPDIR)/.defconfig
	@sed -e "s#config ADK_TARGET#config ADK_NATIVE#" target/mips/sys-available/$(ADKtype) > \
		target/mips/sys-enabled/.$(ADKtype)
	@echo "choice" > $(TOPDIR)/target/config/Config.in.native
	@echo "prompt \"Target system (autodetected)\"" >> $(TOPDIR)/target/config/Config.in.native
	@echo "source \"target/mips/sys-enabled/.$(ADKtype)\"" >> $(TOPDIR)/target/config/Config.in.native
	@echo "endchoice" >> $(TOPDIR)/target/config/Config.in.native
endif
	@echo 'source "target/config/Config.in.arch.default"' > target/config/Config.in.arch
	@echo 'source "target/config/Config.in.arch.choice"' >> target/config/Config.in.arch
	@echo 'source "target/config/Config.in.system.default"' > target/config/Config.in.system
	@echo 'source "target/config/Config.in.system.choice"' >> target/config/Config.in.system
	@if [ ! -z "$(ARCH)" ];then \
		grep "^config" target/config/Config.in.arch.choice \
			|grep -i "$(ARCH)"\$$ \
			|sed -e "s#^config \(.*\)#\1=y#" \
			 >> $(TOPDIR)/.defconfig; \
	fi
	@for symbol in ${DEFCONFIG}; do \
		echo $$symbol >> $(TOPDIR)/.defconfig; \
	done
	@if [ ! -z "$(FS)" ];then \
		grep "^config" target/config/Config.in \
			|grep -i "$(FS)" \
			|sed -e "s#^config \(.*\)#\1=y#" \
			>> $(TOPDIR)/.defconfig; \
	fi
	@if [ ! -z "$(PKG)" ];then \
		grep "^config" target/config/Config.in \
			|grep -i "$(PKG)" \
			|sed -e "s#^config \(.*\)#\1=y#" \
			>> $(TOPDIR)/.defconfig; \
	fi
	@if [ ! -z "$(LIBC)" ];then \
		grep "^config" target/config/Config.in \
			|grep -i "$(LIBC)" \
			|sed -e "s#^config \(.*\)#\1=y#" \
			>> $(TOPDIR)/.defconfig; \
	fi
	@if [ ! -z "$(SYSTEM)" ];then \
		system=$$(echo "$(SYSTEM)" |sed -e "s/-/_/g"); \
		grep -h "^config" target/*/Config.in.systems \
			|grep -i "$$system$$" \
			|sed -e "s#^config \(.*\)#\1=y#" \
			>> $(TOPDIR)/.defconfig; \
	fi
	@if [ ! -z "$(SYSTEM)" ];then \
		$(CONFIG)/conf -D .defconfig $(CONFIG_CONFIG_IN); \
	fi

modconfig:
ifeq (${OStype},Linux)
	@echo ADK_HOST_LINUX=y > $(TOPDIR)/all.config
endif
ifeq (${OStype},FreeBSD)
	@echo ADK_HOST_FREEBSD=y > $(TOPDIR)/all.config
endif
ifeq (${OStype},MirBSD)
	@echo ADK_HOST_MIRBSD=y > $(TOPDIR)/all.config
endif
ifeq (${OStype},OpenBSD)
	@echo ADK_HOST_OPENBSD=y > $(TOPDIR)/all.config
endif
ifeq (${OStype},NetBSD)
	@echo ADK_HOST_NETBSD=y > $(TOPDIR)/all.config
endif
ifeq (${OStype},Darwin)
	@echo ADK_HOST_DARWIN=y > $(TOPDIR)/all.config
endif
ifneq (,$(filter CYGWIN%,${OStype}))
	@echo ADK_HOST_CYGWIN=y > $(TOPDIR)/all.config
endif
ifeq ($(ADKtype),ibm-x40)
	@echo ADK_TARGET_SYSTEM_IBM_X40=y >> $(TOPDIR)/all.config
	@sed -e "s#TARGET#NATIVE#" target/$(ARCH_FOR_BUILD)/sys-available/$(ADKtype) > \
		target/$(ARCH_FOR_BUILD)/sys-enabled/.$(ADKtype)
	@echo "choice" > $(TOPDIR)/target/config/Config.in.native
	@echo "prompt \"Target system (autodetected)\"" >> $(TOPDIR)/target/config/Config.in.native
	@echo "source \"target/$(ARCH_FOR_BUILD)/sys-enabled/.$(ADKtype)\"" >> $(TOPDIR)/target/config/Config.in.native
	@echo "endchoice" >> $(TOPDIR)/target/config/Config.in.native
endif
ifeq ($(ADKtype),lemote-yeelong)
	@echo ADK_TARGET_SYSTEM_LEMOTE_YEELONG=y >> $(TOPDIR)/all.config
	@sed -e "s#TARGET#NATIVE#" target/$(ARCH_FOR_BUILD)/sys-available/$(ADKtype) > \
		target/$(ARCH_FOR_BUILD)/sys-enabled/.$(ADKtype)
	@echo "choice" > $(TOPDIR)/target/config/Config.in.native
	@echo "prompt \"Target system (autodetected)\"" >> $(TOPDIR)/target/config/Config.in.native
	@echo "source \"target/$(ARCH_FOR_BUILD)/sys-enabled/.$(ADKtype)\"" >> $(TOPDIR)/target/config/Config.in.native
	@echo "endchoice" >> $(TOPDIR)/target/config/Config.in.native
endif
	@echo 'source "target/config/Config.in.arch.default"' > target/config/Config.in.arch
	@echo 'source "target/config/Config.in.arch.choice"' >> target/config/Config.in.arch
	@echo 'source "target/config/Config.in.system.default"' > target/config/Config.in.system
	@echo 'source "target/config/Config.in.system.choice"' >> target/config/Config.in.system
	@if [ ! -z "$(ARCH)" ];then \
		grep "^config" target/config/Config.in.arch.choice \
			|grep -i "$(ARCH)"\$$ \
			|sed -e "s#^config \(.*\)#\1=y#" \
			>> $(TOPDIR)/all.config; \
	fi
	@for symbol in ${DEFCONFIG}; do \
		echo $$symbol >> $(TOPDIR)/all.config; \
	done
	@if [ ! -z "$(FS)" ];then \
		grep "^config" target/config/Config.in \
			|grep -i "$(FS)" \
			|sed -e "s#^config \(.*\)#\1=y#" \
			>> $(TOPDIR)/all.config; \
	fi
	@if [ ! -z "$(PKG)" ];then \
		grep "^config" target/config/Config.in \
			|grep -i "$(PKG)" \
			|sed -e "s#^config \(.*\)#\1=y#" \
			>> $(TOPDIR)/all.config; \
	fi
	@if [ ! -z "$(LIBC)" ];then \
		grep "^config" target/config/Config.in \
			|grep -i "$(LIBC)" \
			|sed -e "s#^config \(.*\)#\1=y#" \
			>> $(TOPDIR)/all.config; \
	fi
	@if [ ! -z "$(SYSTEM)" ];then \
		system=$$(echo "$(SYSTEM)" |sed -e "s/-/_/g"); \
		grep -h "^config" target/*/Config.in.systems \
			|grep -i "$$system" \
			|sed -e "s#^config \(.*\)#\1=y#" \
			>> $(TOPDIR)/all.config; \
	fi

menuconfig: $(CONFIG)/mconf defconfig .menu package/Config.in.auto
	@${BASH} ${TOPDIR}/scripts/update-sys
	@${BASH} ${TOPDIR}/scripts/update-pkg
	@if [ ! -f .config ];then \
		$(CONFIG)/conf -D .defconfig $(CONFIG_CONFIG_IN); \
	fi
	@$(CONFIG)/mconf $(CONFIG_CONFIG_IN)
	${POSTCONFIG}

guiconfig: $(CONFIG)/gconf defconfig .menu package/Config.in.auto
	@${BASH} ${TOPDIR}/scripts/update-sys
	@${BASH} ${TOPDIR}/scripts/update-pkg
	@if [ ! -f .config ];then \
		$(CONFIG)/conf -D .defconfig $(CONFIG_CONFIG_IN); \
	fi
	@$(CONFIG)/gconf $(CONFIG_CONFIG_IN)
	${POSTCONFIG}

_config: $(CONFIG)/conf .menu package/Config.in.auto
	-@touch .config
	@$(CONFIG)/conf ${W} $(CONFIG_CONFIG_IN)
	${POSTCONFIG}

.NOTPARALLEL: _mconfig
_mconfig: ${CONFIG}/conf _mconfig2 _config
_mconfig2: ${CONFIG}/conf modconfig .menu
	@${CONFIG}/conf -m ${RCONFIG} >/dev/null

distclean:
	@$(MAKE) -C $(CONFIG) clean
	@rm -rf $(BUILD_DIR_PFX) $(FW_DIR_PFX) $(TARGET_DIR_PFX) $(DISTDIR) \
	    ${TOPDIR}/package/pkglist.d ${TOPDIR}/package/pkgconfigs.d
	@rm -rf $(TOOLCHAIN_BUILD_DIR_PFX) $(STAGING_TARGET_DIR_PFX) $(TOOLS_BUILD_DIR)
	@rm -rf $(STAGING_HOST_DIR_PFX) $(STAGING_TARGET_DIR_PFX) $(STAGING_PKG_DIR_PFX)
	@rm -f .adkinit .config* .defconfig .tmpconfig.h all.config ${TOPDIR}/prereq.mk \
	    .menu .rebuild.* ${TOPDIR}/package/Depends.mk .ADK_HAVE_DOT_CONFIG


endif # ! ifeq ($(strip $(ADK_HAVE_DOT_CONFIG)),y)

# build all target architecture and libc combinations (toolchain only)
bulktoolchain:
	for libc in glibc eglibc uclibc musl;do \
		while read arch; do \
		    mkdir -p $(TOPDIR)/firmware/toolchain_$${arch}_$$libc; \
		    ( \
			echo === building $$arch $$libc toolchain-$$arch on $$(date); \
			tarch=$$(echo $$arch|sed -e "s#el##" -e "s#eb##" -e "s#mips64.*#mips#"); \
			$(GMAKE) prereq && \
				$(GMAKE) ARCH=$$tarch SYSTEM=toolchain-$$arch LIBC=$$libc defconfig; \
				$(GMAKE) VERBOSE=1 all; if [ $$? -ne 0 ]; then touch .exit;fi; \
				tar -cJf ${TOPDIR}/firmware/toolchain_$${arch}_$${libc}.tar.xz host_$${arch}_*_$${libc} target_$${arch}_*_$${libc}; \
			rm .config; \
		    ) 2>&1 | tee $(TOPDIR)/firmware/toolchain_$${arch}_$${libc}/build.log; \
		    if [ -f .exit ];then break;fi \
		done <${TOPDIR}/target/tarch.lst ;\
		if [ -f .exit ];then echo "Bulk build failed!"; rm .exit; exit 1;fi \
	done

release:
	for libc in uclibc eglibc glibc musl;do \
		mkdir -p $(TOPDIR)/firmware/$(SYSTEM)_$(ARCH)_$$libc; \
		( \
			echo === building $$libc on $$(date); \
			$(GMAKE) prereq && \
			$(GMAKE) ARCH=$(ARCH) SYSTEM=$(SYSTEM) LIBC=$$libc FS=archive allmodconfig; \
			$(GMAKE) VERBOSE=1 all; if [ $$? -ne 0 ]; then touch .exit; exit 1;fi; \
			rm .config; \
		) 2>&1 | tee $(TOPDIR)/firmware/$(SYSTEM)_$(ARCH)_$$libc/build.log; \
		if [ -f .exit ];then echo "Bulk build failed!"; break;fi \
	done
	if [ -f .exit ];then rm .exit;exit 1;fi

# build all target architecture, target systems and libc combinations
bulk:
	for libc in uclibc eglibc glibc musl;do \
	  while read arch; do \
	      systems=$$(./scripts/getsystems $$arch|grep -v toolchain); \
	      for system in $$systems;do \
		mkdir -p $(TOPDIR)/firmware/$${system}_$${arch}_$$libc; \
	    ( \
		echo === building $$arch $$system $$libc on $$(date); \
		$(GMAKE) prereq && \
		$(GMAKE) ARCH=$$arch SYSTEM=$$system LIBC=$$libc FS=archive defconfig; \
		$(GMAKE) VERBOSE=1 all; if [ $$? -ne 0 ]; then touch .exit; exit 1;fi; \
		rm .config; \
            ) 2>&1 | tee $(TOPDIR)/firmware/$${system}_$${arch}_$$libc/build.log; \
		if [ -f .exit ]; then break;fi \
	      done; \
	    if [ -f .exit ]; then break;fi \
	  done <${TOPDIR}/target/arch.lst ;\
	  if [ -f .exit ];then echo "Bulk build failed!"; rm .exit; exit 1;fi \
	done

bulkall:
	for libc in uclibc eglibc glibc musl;do \
	  while read arch; do \
	      systems=$$(./scripts/getsystems $$arch| grep -v toolchain); \
	      for system in $$systems;do \
		mkdir -p $(TOPDIR)/firmware/$${system}_$${arch}_$$libc; \
	    ( \
		echo === building $$arch $$system $$libc on $$(date); \
		$(GMAKE) prereq && \
		$(GMAKE) ARCH=$$arch SYSTEM=$$system LIBC=$$libc FS=archive allconfig; \
		$(GMAKE) VERBOSE=1 all; if [ $$? -ne 0 ]; then touch .exit; exit 1;fi; \
		rm .config; \
            ) 2>&1 | tee $(TOPDIR)/firmware/$${system}_$${arch}_$$libc/build.log; \
		if [ -f .exit ]; then break;fi \
	      done; \
	      if [ -f .exit ]; then break;fi \
	  done <${TOPDIR}/target/arch.lst ;\
	    if [ -f .exit ];then echo "Bulk build failed!"; rm .exit; exit 1;fi \
	done

bulkallmod:
	for libc in uclibc eglibc glibc musl;do \
	  while read arch; do \
	      systems=$$(./scripts/getsystems $$arch| grep -v toolchain); \
	      for system in $$systems;do \
		mkdir -p $(TOPDIR)/firmware/$${system}_$${arch}_$$libc; \
	    ( \
		echo === building $$arch $$system $$libc on $$(date); \
		$(GMAKE) prereq && \
		$(GMAKE) ARCH=$$arch SYSTEM=$$system LIBC=$$libc FS=archive allmodconfig; \
		$(GMAKE) VERBOSE=1 all; if [ $$? -ne 0 ]; then echo $$system-$$libc >.exit; exit 1;fi; \
		$(GMAKE) cleantarget; \
		rm .config; \
            ) 2>&1 | tee $(TOPDIR)/firmware/$${system}_$${arch}_$$libc/build.log; \
	        if [ -f .exit ]; then break;fi \
	      done; \
	     if [ -f .exit ]; then break;fi \
	  done <${TOPDIR}/target/arch.lst ;\
	  if [ -f .exit ];then echo "Bulk build failed!"; cat .exit;rm .exit; exit 1;fi \
	done

$(TOPDIR)/host_$(GNU_HOST_NAME)/usr/bin/pkgmaker: $(TOPDIR)/tools/adk/pkgmaker.c $(TOPDIR)/tools/adk/sortfile.c $(TOPDIR)/tools/adk/strmap.c
	@mkdir -p host_$(GNU_HOST_NAME)/usr/bin
	@$(CC_FOR_BUILD) -g -o $@ tools/adk/pkgmaker.c tools/adk/sortfile.c tools/adk/strmap.c

$(TOPDIR)/host_$(GNU_HOST_NAME)/usr/bin/pkgrebuild: $(TOPDIR)/tools/adk/pkgrebuild.c $(TOPDIR)/tools/adk/strmap.c
	@$(CC_FOR_BUILD) -g -o $@ tools/adk/pkgrebuild.c tools/adk/strmap.c

package/Config.in.auto menu .menu: $(wildcard ${TOPDIR}/package/*/Makefile) $(TOPDIR)/host_$(GNU_HOST_NAME)/usr/bin/pkgmaker $(TOPDIR)/host_$(GNU_HOST_NAME)/usr/bin/pkgrebuild
	@echo "Generating menu structure ..."
	@$(TOPDIR)/host_$(GNU_HOST_NAME)/usr/bin/pkgmaker
	@:>.menu

$(TOPDIR)/host_$(GNU_HOST_NAME)/usr/bin/depmaker: $(TOPDIR)/tools/adk/depmaker.c
	$(CC_FOR_BUILD) -g -o $@ $(TOPDIR)/tools/adk/depmaker.c

dep: $(TOPDIR)/host_$(GNU_HOST_NAME)/usr/bin/depmaker
	@echo "Generating dependencies ..."
	@$(TOPDIR)/host_$(GNU_HOST_NAME)/usr/bin/depmaker > ${TOPDIR}/package/Depends.mk

.PHONY: menu dep

include $(TOPDIR)/toolchain/gcc/Makefile.inc

check-dejagnu:
	@-rm tests/adk.exp tests/master.exp >/dev/null 2>&1
	@sed -e "s#@ADK_TARGET_IP@#$(ADK_TARGET_IP)#" tests/adk.exp.in > \
		tests/adk.exp.in.tmp
	@sed -e "s#@ADK_TARGET_PORT@#$(ADK_TARGET_PORT)#" tests/adk.exp.in.tmp > \
		tests/adk.exp
	@sed -e "s#@TOPDIR@#$(TOPDIR)#" tests/master.exp.in > \
		tests/master.exp

check-gcc: check-dejagnu
	env DEJAGNU=$(TOPDIR)/tests/master.exp \
	$(MAKE) -C $(TOOLCHAIN_BUILD_DIR)/w-$(PKG_NAME)-$(PKG_VERSION)-$(PKG_RELEASE)/$(PKG_NAME)-$(PKG_VERSION)-final/gcc check-gcc

check-g++: check-dejagnu
	env DEJAGNU=$(TOPDIR)/tests/master.exp \
	$(MAKE) -C $(TOOLCHAIN_BUILD_DIR)/w-$(PKG_NAME)-$(PKG_VERSION)-$(PKG_RELEASE)/$(PKG_NAME)-$(PKG_VERSION)-final/gcc check-g++

check: check-gcc check-g++

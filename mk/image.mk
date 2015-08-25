# This file is part of the OpenADK project. OpenADK is copyrighted
# material, please see the LICENCE file in the top-level directory.

# relative paths, like 'mksh' or '../usr/bin/foosh'
ifeq (${ADK_BINSH_ASH},y)
BINSH:=ash
else ifeq (${ADK_BINSH_BASH},y)
BINSH:=bash
else ifeq (${ADK_BINSH_SASH},y)
BINSH:=sash
else ifeq (${ADK_BINSH_HUSH},y)
BINSH:=hush
else ifeq (${ADK_BINSH_MKSH},y)
BINSH:=mksh
else ifeq (${ADK_BINSH_ZSH},y)
BINSH:=zsh
else
$(error No /bin/sh configured!)
endif

# absolute paths
ifeq (${ADK_ROOTSH_ASH},y)
ROOTSH:=/bin/ash
else ifeq (${ADK_ROOTSH_BASH},y)
ROOTSH:=/bin/bash
else ifeq (${ADK_ROOTSH_SASH},y)
ROOTSH:=/bin/sash
else ifeq (${ADK_ROOTSH_HUSH},y)
ROOTSH:=/bin/hush
else ifeq (${ADK_ROOTSH_MKSH},y)
ROOTSH:=/bin/mksh
else ifeq (${ADK_ROOTSH_TCSH},y)
ROOTSH:=/usr/bin/tcsh
else ifeq (${ADK_ROOTSH_ZSH},y)
ROOTSH:=/bin/zsh
else
$(error No login shell configured!)
endif

imageprepare: image-prepare-post extra-install prelink

# if an extra directory exist in ADK_TOPDIR, copy all content over the 
# root directory, do the same if make extra=/dir/to/extra is used
extra-install:
	@-if [ -h ${TARGET_DIR}/etc/resolv.conf -a -f $(ADK_TOPDIR)/extra/etc/resolv.conf ];then \
		rm ${TARGET_DIR}/etc/resolv.conf;\
	fi
	@if [ -d $(ADK_TOPDIR)/extra ];then $(CP) $(ADK_TOPDIR)/extra/* ${TARGET_DIR};fi
	@if [ ! -z $(extra) ];then $(CP) $(extra)/* ${TARGET_DIR};fi

image-prepare-post:
	$(BASH) $(ADK_TOPDIR)/scripts/update-rcconf
	rng=/dev/arandom; test -e $$rng || rng=/dev/urandom; \
	    dd if=$$rng bs=512 count=1 >>${TARGET_DIR}/etc/.rnd 2>/dev/null; \
	    chmod 600 ${TARGET_DIR}/etc/.rnd
	@-if [ -d ${TARGET_DIR}/usr/share/fonts/X11 ];then \
		for i in $$(ls ${TARGET_DIR}/usr/share/fonts/X11/);do \
			mkfontdir ${TARGET_DIR}/usr/share/fonts/X11/$${i}; \
		done; \
	fi
	$(SED) '/^root:/s!:/bin/sh$$!:${ROOTSH}!' ${TARGET_DIR}/etc/passwd
	-rm -f ${TARGET_DIR}/bin/sh
	ln -sf ${BINSH} ${TARGET_DIR}/bin/sh
	test -z $(GIT) || \
	     $(GIT) log -1|head -1|sed -e 's#commit ##' \
		> $(TARGET_DIR)/etc/.adkgithash
	echo $(ADK_APPLIANCE_VERSION) > $(TARGET_DIR)/etc/.adkversion
	echo $(ADK_TARGET_SYSTEM) > $(TARGET_DIR)/etc/.adktarget
ifneq (${ADK_PACKAGE_CONFIG_IN_ETC},)
	gzip -9c ${ADK_TOPDIR}/.config > $(TARGET_DIR)/etc/adkconfig.gz
	chmod 600 $(TARGET_DIR)/etc/adkconfig.gz
endif
ifneq ($(ADK_TARGET_ARCH_AARCH64)$(ADK_TARGET_ARCH_X86_64)$(ADK_TARGET_ARCH_PPC64)$(ADK_TARGET_ARCH_SPARC64)$(ADK_TARGET_ABI_N32)$(ADK_TARGET_ABI_N64),)
	test ! -d ${TARGET_DIR}/lib || mv ${TARGET_DIR}/lib/* ${TARGET_DIR}/${ADK_TARGET_LIBC_PATH}
	test ! -d ${TARGET_DIR}/lib || rm -rf ${TARGET_DIR}/lib
	ln -sf /${ADK_TARGET_LIBC_PATH} ${TARGET_DIR}/lib
	mkdir -p ${TARGET_DIR}/usr/${ADK_TARGET_LIBC_PATH} 2>/dev/null
	-test ! -d ${TARGET_DIR}/usr/lib || mv ${TARGET_DIR}/usr/lib/* ${TARGET_DIR}/usr/${ADK_TARGET_LIBC_PATH} 2>/dev/null
	test ! -d ${TARGET_DIR}/usr/lib || rm -rf ${TARGET_DIR}/usr/lib/
	(cd ${TARGET_DIR}/usr ; ln -sf ${ADK_TARGET_LIBC_PATH} lib)
endif

ifeq (${ADK_PRELINK},)
prelink:
else
${TARGET_DIR}/etc/prelink.conf:
	echo '/' > $@

prelink: ${TARGET_DIR}/etc/prelink.conf
	$(TRACE) target/prelink
	${TARGET_CROSS}prelink ${ADK_PRELINK_OPTS} \
		--ld-library-path=${STAGING_TARGET_DIR}/usr/lib:${STAGING_TARGET_DIR}/lib \
		--root=${TARGET_DIR} -a $(MAKE_TRACE)
endif

KERNEL_PKGDIR:=$(LINUX_BUILD_DIR)/kernel-pkg
KERNEL_PKG:=$(PACKAGE_DIR)/kernel_$(KERNEL_VERSION)_$(ADK_TARGET_CPU_ARCH).$(PKG_SUFFIX)
TARGET_KERNEL=		${ADK_TARGET_SYSTEM}-${ADK_TARGET_FS}-kernel
INITRAMFS=		${ADK_TARGET_SYSTEM}-${ADK_TARGET_LIBC}-${ADK_TARGET_FS}
ROOTFSSQUASHFS=		${ADK_TARGET_SYSTEM}-${ADK_TARGET_LIBC}-${ADK_TARGET_FS}.img
ROOTFSJFFS2=		${ADK_TARGET_SYSTEM}-${ADK_TARGET_LIBC}-jffs2.img
ROOTFSTARBALL=		${ADK_TARGET_SYSTEM}-${ADK_TARGET_LIBC}-${ADK_TARGET_FS}+kernel.tar.xz
ROOTFSUSERTARBALL=	${ADK_TARGET_SYSTEM}-${ADK_TARGET_LIBC}-${ADK_TARGET_FS}.tar.xz
ROOTFSISO=		${ADK_TARGET_SYSTEM}-${ADK_TARGET_LIBC}.iso

kernel-package: kernel-strip
	$(TRACE) target/$(ADK_TARGET_ARCH)-create-kernel-package
	rm -rf $(KERNEL_PKGDIR)
	@mkdir -p $(KERNEL_PKGDIR)/boot
	cp $(BUILD_DIR)/$(TARGET_KERNEL) $(KERNEL_PKGDIR)/boot/kernel
	@${BASH} ${SCRIPT_DIR}/make-ipkg-dir.sh ${KERNEL_PKGDIR} \
	    ../linux/kernel.control ${KERNEL_VERSION} ${ADK_TARGET_CPU_ARCH}
	$(PKG_BUILD) $(KERNEL_PKGDIR) $(PACKAGE_DIR) $(MAKE_TRACE)
	$(TRACE) target/$(ADK_TARGET_ARCH)-install-kernel-package
	$(PKG_INSTALL) $(KERNEL_PKG) $(MAKE_TRACE)

${FW_DIR}/${ROOTFSTARBALL}: ${TARGET_DIR}/.adk kernel-package
	cd ${TARGET_DIR}; find . | sed -n '/^\.\//s///p' | \
		sed "s#\(.*\)#:0:0::::::\1#" | sort | \
		${STAGING_HOST_DIR}/usr/bin/cpio -o -Hustar -P | $(XZ) -c >$@
ifeq ($(ADK_TARGET_QEMU),y)
	@cp $(KERNEL) $(FW_DIR)/$(TARGET_KERNEL)
endif

${FW_DIR}/${ROOTFSUSERTARBALL}: ${TARGET_DIR}/.adk
	cd ${TARGET_DIR}; find . | grep -v ./boot/ | sed -n '/^\.\//s///p' | \
		sed "s#\(.*\)#:0:0::::::\1#" | sort | \
		${STAGING_HOST_DIR}/usr/bin/cpio -o -Hustar -P | $(XZ) -c >$@

${STAGING_TARGET_DIR}/${INITRAMFS}_list: ${TARGET_DIR}/.adk
	env PATH='${HOST_PATH}' $(BASH) ${LINUX_DIR}/scripts/gen_initramfs_list.sh -u squash -g squash \
		${TARGET_DIR}/ >$@

${FW_DIR}/${INITRAMFS}: ${STAGING_TARGET_DIR}/${INITRAMFS}_list
	${LINUX_DIR}/usr/gen_init_cpio ${STAGING_TARGET_DIR}/${INITRAMFS}_list | \
		${ADK_COMPRESSION_TOOL} -c >$@

${BUILD_DIR}/root.squashfs: ${TARGET_DIR}/.adk
	${STAGING_HOST_DIR}/usr/bin/mksquashfs ${TARGET_DIR} \
		${BUILD_DIR}/root.squashfs -comp xz \
		-nopad -noappend -root-owned $(MAKE_TRACE)

${FW_DIR}/${ROOTFSJFFS2}: ${TARGET_DIR}
	${STAGING_HOST_DIR}/usr/bin/mkfs.jffs2 $(ADK_JFFS2_OPTS) -q -r ${TARGET_DIR} \
		--pad=$(ADK_TARGET_MTD_SIZE) -o ${FW_DIR}/${ROOTFSJFFS2} $(MAKE_TRACE)

createinitramfs: ${STAGING_TARGET_DIR}/${INITRAMFS}_list
	${SED} 's/.*CONFIG_\(RD_\|BLK_DEV_INITRD\|INITRAMFS_\).*//' \
		${LINUX_DIR}/.config
	( \
		echo "CONFIG_BLK_DEV_INITRD=y"; \
		echo "CONFIG_ACPI_INITRD_TABLE_OVERRIDE=n"; \
		echo 'CONFIG_INITRAMFS_SOURCE="${STAGING_TARGET_DIR}/${INITRAMFS}_list"'; \
		echo '# CONFIG_INITRAMFS_COMPRESSION_NONE is not set'; \
		echo '# CONFIG_CRC32_SELFTEST is not set'; \
		echo '# CONFIG_CRC32_SLICEBY8 is not set'; \
		echo '# CONFIG_CRC32_SLICEBY4 is not set'; \
		echo '# CONFIG_CRC32_SARWATE is not set'; \
		echo 'CONFIG_CRC32_BIT=y'; \
		echo 'CONFIG_INITRAMFS_ROOT_UID=0'; \
		echo 'CONFIG_INITRAMFS_ROOT_GID=0'; \
	) >> ${LINUX_DIR}/.config
ifeq ($(ADK_KERNEL_COMP_XZ),y)
		echo "CONFIG_RD_BZIP2=n" >> ${LINUX_DIR}/.config
		echo "CONFIG_RD_GZIP=n" >> ${LINUX_DIR}/.config
		echo "CONFIG_RD_LZMA=n" >> ${LINUX_DIR}/.config
		echo "CONFIG_RD_LZ4=n" >> ${LINUX_DIR}/.config
		echo "CONFIG_RD_LZO=n" >> ${LINUX_DIR}/.config
		echo "CONFIG_RD_XZ=y" >> ${LINUX_DIR}/.config
		echo "CONFIG_INITRAMFS_COMPRESSION_XZ=y" >> ${LINUX_DIR}/.config
		echo "CONFIG_XZ_DEC_X86=n" >> ${LINUX_DIR}/.config
		echo "CONFIG_XZ_DEC_POWERPC=n" >> ${LINUX_DIR}/.config
		echo "CONFIG_XZ_DEC_IA64=n" >> ${LINUX_DIR}/.config
		echo "CONFIG_XZ_DEC_ARM=n" >> ${LINUX_DIR}/.config
		echo "CONFIG_XZ_DEC_ARMTHUMB=n" >> ${LINUX_DIR}/.config
		echo "CONFIG_XZ_DEC_SPARC=n" >> ${LINUX_DIR}/.config
		echo "CONFIG_XZ_DEC_TEST=n" >> ${LINUX_DIR}/.config
endif
ifeq ($(ADK_KERNEL_COMP_LZ4),y)
		echo "CONFIG_RD_XZ=n" >> ${LINUX_DIR}/.config
		echo "CONFIG_RD_BZIP2=n" >> ${LINUX_DIR}/.config
		echo "CONFIG_RD_GZIP=n" >> ${LINUX_DIR}/.config
		echo "CONFIG_RD_LZO=n" >> ${LINUX_DIR}/.config
		echo "CONFIG_RD_LZ4=y" >> ${LINUX_DIR}/.config
		echo "CONFIG_RD_LZMA=n" >> ${LINUX_DIR}/.config
		echo "CONFIG_INITRAMFS_COMPRESSION_LZ4=y" >> ${LINUX_DIR}/.config
endif
ifeq ($(ADK_KERNEL_COMP_LZMA),y)
		echo "CONFIG_RD_XZ=n" >> ${LINUX_DIR}/.config
		echo "CONFIG_RD_BZIP2=n" >> ${LINUX_DIR}/.config
		echo "CONFIG_RD_GZIP=n" >> ${LINUX_DIR}/.config
		echo "CONFIG_RD_LZO=n" >> ${LINUX_DIR}/.config
		echo "CONFIG_RD_LZ4=n" >> ${LINUX_DIR}/.config
		echo "CONFIG_RD_LZMA=y" >> ${LINUX_DIR}/.config
		echo "CONFIG_INITRAMFS_COMPRESSION_LZMA=y" >> ${LINUX_DIR}/.config
endif
ifeq ($(ADK_KERNEL_COMP_LZO),y)
		echo "CONFIG_RD_XZ=n" >> ${LINUX_DIR}/.config
		echo "CONFIG_RD_BZIP2=n" >> ${LINUX_DIR}/.config
		echo "CONFIG_RD_GZIP=n" >> ${LINUX_DIR}/.config
		echo "CONFIG_RD_LZMA=n" >> ${LINUX_DIR}/.config
		echo "CONFIG_RD_LZ4=n" >> ${LINUX_DIR}/.config
		echo "CONFIG_RD_LZO=y" >> ${LINUX_DIR}/.config
		echo "CONFIG_INITRAMFS_COMPRESSION_LZO=y" >> ${LINUX_DIR}/.config
endif
ifeq ($(ADK_KERNEL_COMP_GZIP),y)
		echo "CONFIG_RD_XZ=n" >> ${LINUX_DIR}/.config
		echo "CONFIG_RD_BZIP2=n" >> ${LINUX_DIR}/.config
		echo "CONFIG_RD_LZO=n" >> ${LINUX_DIR}/.config
		echo "CONFIG_RD_LZMA=n" >> ${LINUX_DIR}/.config
		echo "CONFIG_RD_LZ4=n" >> ${LINUX_DIR}/.config
		echo "CONFIG_RD_GZIP=y" >> ${LINUX_DIR}/.config
		echo "CONFIG_INITRAMFS_COMPRESSION_GZIP=y" >> ${LINUX_DIR}/.config
endif
ifeq ($(ADK_KERNEL_COMP_BZIP2),y)
		echo "CONFIG_RD_XZ=n" >> ${LINUX_DIR}/.config
		echo "CONFIG_RD_GZIP=n" >> ${LINUX_DIR}/.config
		echo "CONFIG_RD_LZMA=n" >> ${LINUX_DIR}/.config
		echo "CONFIG_RD_LZO=n" >> ${LINUX_DIR}/.config
		echo "CONFIG_RD_LZ4=n" >> ${LINUX_DIR}/.config
		echo "CONFIG_RD_BZIP2=y" >> ${LINUX_DIR}/.config
		echo "CONFIG_INITRAMFS_COMPRESSION_BZIP2=y" >> ${LINUX_DIR}/.config
endif
	@-rm $(LINUX_DIR)/usr/initramfs_data.cpio* 2>/dev/null
	env $(KERNEL_MAKE_ENV) $(MAKE) -C "${LINUX_DIR}" $(KERNEL_MAKE_OPTS) \
		-j${ADK_MAKE_JOBS} $(ADK_TARGET_KERNEL) $(MAKE_TRACE)
	@cp $(KERNEL) $(FW_DIR)/$(TARGET_KERNEL)

${FW_DIR}/${ROOTFSISO}: ${TARGET_DIR} kernel-package
	mkdir -p ${TARGET_DIR}/boot/syslinux
	cp ${STAGING_HOST_DIR}/usr/share/syslinux/{isolinux.bin,ldlinux.c32} \
		${TARGET_DIR}/boot/syslinux
	echo 'DEFAULT /boot/kernel root=/dev/sr0' > \
		${TARGET_DIR}/boot/syslinux/isolinux.cfg
	PATH='${HOST_PATH}' mkisofs -R -uid 0 -gid 0 -o $@ \
		-b boot/syslinux/isolinux.bin \
		-c boot/syslinux/boot.cat -no-emul-boot \
		-boot-load-size 4 -boot-info-table ${TARGET_DIR}

imageclean:
	rm -f $(FW_DIR)/$(ADK_TARGET_SYSTEM)-* ${BUILD_DIR}/$(ADK_TARGET_SYSTEM)-*

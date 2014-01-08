# This file is part of the OpenADK project. OpenADK is copyrighted
# material, please see the LICENCE file in the top-level directory.

# relative paths, like 'mksh' or '../usr/bin/foosh'
ifeq (${ADK_BINSH_ASH},y)
BINSH:=ash
else ifeq (${ADK_BINSH_BASH},y)
BINSH:=bash
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
else ifeq (${ADK_ROOTSH_MKSH},y)
ROOTSH:=/bin/mksh
else ifeq (${ADK_ROOTSH_TCSH},y)
ROOTSH:=/usr/bin/tcsh
else ifeq (${ADK_ROOTSH_ZSH},y)
ROOTSH:=/bin/zsh
else
$(error No login shell configured!)
endif

imageprepare: image-prepare-post extra-install

# if an extra directory exist in TOPDIR, copy all content over the 
# root directory, do the same if make extra=/dir/to/extra is used
extra-install:
	@if [ -d $(TOPDIR)/extra ];then $(CP) $(TOPDIR)/extra/* ${TARGET_DIR};fi
	@if [ ! -z $(extra) ];then $(CP) $(extra)/* ${TARGET_DIR};fi

image-prepare-post:
	rng=/dev/arandom; test -e $$rng || rng=/dev/urandom; \
	    dd if=$$rng bs=512 count=1 >>${TARGET_DIR}/etc/.rnd 2>/dev/null; \
	    chmod 600 ${TARGET_DIR}/etc/.rnd
	chmod 4511 ${TARGET_DIR}/bin/busybox
	@-if [ -d ${TARGET_DIR}/usr/share/fonts/X11 ];then \
		for i in $$(ls ${TARGET_DIR}/usr/share/fonts/X11/);do \
			mkfontdir ${TARGET_DIR}/usr/share/fonts/X11/$${i}; \
		done; \
	fi
	sed -i '/^root:/s!:/bin/sh$$!:${ROOTSH}!' ${TARGET_DIR}/etc/passwd
	-rm -f ${TARGET_DIR}/bin/sh
	ln -sf ${BINSH} ${TARGET_DIR}/bin/sh
ifeq ($(ADK_LINUX_X86_64),y)
	# fixup lib dirs
	mv ${TARGET_DIR}/lib/* ${TARGET_DIR}/${ADK_TARGET_LIBC_PATH}
	rm -rf ${TARGET_DIR}/lib/
	ln -sf /${ADK_TARGET_LIBC_PATH} ${TARGET_DIR}/lib
	-mkdir ${TARGET_DIR}/usr/${ADK_TARGET_LIBC_PATH} 2>/dev/null
	mv ${TARGET_DIR}/usr/lib/* ${TARGET_DIR}/usr/${ADK_TARGET_LIBC_PATH}
	rm -rf ${TARGET_DIR}/usr/lib/
	(cd ${TARGET_DIR}/usr ; ln -sf ${ADK_TARGET_LIBC_PATH} lib)
endif
ifeq ($(ADK_LINUX_PPC64),y)
	# fixup lib dirs
	mv ${TARGET_DIR}/lib/* ${TARGET_DIR}/${ADK_TARGET_LIBC_PATH}
	rm -rf ${TARGET_DIR}/lib/
	ln -sf /${ADK_TARGET_LIBC_PATH} ${TARGET_DIR}/lib
	-mkdir ${TARGET_DIR}/usr/${ADK_TARGET_LIBC_PATH} 2>/dev/null
	mv ${TARGET_DIR}/usr/lib/* ${TARGET_DIR}/usr/${ADK_TARGET_LIBC_PATH}
	rm -rf ${TARGET_DIR}/usr/lib/
	(cd ${TARGET_DIR}/usr ; ln -sf ${ADK_TARGET_LIBC_PATH} lib)
endif
ifeq ($(ADK_LINUX_SPARC64),y)
	# fixup lib dirs
	mv ${TARGET_DIR}/lib/* ${TARGET_DIR}/${ADK_TARGET_LIBC_PATH}
	rm -rf ${TARGET_DIR}/lib/
	ln -sf /${ADK_TARGET_LIBC_PATH} ${TARGET_DIR}/lib
	-mkdir ${TARGET_DIR}/usr/${ADK_TARGET_LIBC_PATH} 2>/dev/null
	mv ${TARGET_DIR}/usr/lib/* ${TARGET_DIR}/usr/${ADK_TARGET_LIBC_PATH}
	rm -rf ${TARGET_DIR}/usr/lib/
	(cd ${TARGET_DIR}/usr ; ln -sf ${ADK_TARGET_LIBC_PATH} lib)
endif
ifeq ($(ADK_TARGET_ABI_N32),y)
	# fixup lib dirs
	mv ${TARGET_DIR}/lib/* ${TARGET_DIR}/${ADK_TARGET_LIBC_PATH}
	rm -rf ${TARGET_DIR}/lib/
	ln -sf /${ADK_TARGET_LIBC_PATH} ${TARGET_DIR}/lib
	-mkdir ${TARGET_DIR}/usr/${ADK_TARGET_LIBC_PATH} 2>/dev/null
	mv ${TARGET_DIR}/usr/lib/* ${TARGET_DIR}/usr/${ADK_TARGET_LIBC_PATH}
	rm -rf ${TARGET_DIR}/usr/lib/
	(cd ${TARGET_DIR}/usr ; ln -sf ${ADK_TARGET_LIBC_PATH} lib)
endif
ifeq ($(ADK_TARGET_ABI_N64),y)
	# fixup lib dirs
	mv ${TARGET_DIR}/lib/* ${TARGET_DIR}/${ADK_TARGET_LIBC_PATH}
	rm -rf ${TARGET_DIR}/lib/
	ln -sf /${ADK_TARGET_LIBC_PATH} ${TARGET_DIR}/lib
	-mkdir ${TARGET_DIR}/usr/${ADK_TARGET_LIBC_PATH} 2>/dev/null
	mv ${TARGET_DIR}/usr/lib/* ${TARGET_DIR}/usr/${ADK_TARGET_LIBC_PATH}
	rm -rf ${TARGET_DIR}/usr/lib/
	(cd ${TARGET_DIR}/usr ; ln -sf ${ADK_TARGET_LIBC_PATH} lib)
endif

KERNEL_PKGDIR:=$(LINUX_BUILD_DIR)/kernel-pkg
KERNEL_PKG:=$(PACKAGE_DIR)/kernel_$(KERNEL_VERSION)_$(CPU_ARCH).$(PKG_SUFFIX)

kernel-package: $(KERNEL)
	$(TRACE) target/$(ADK_TARGET_ARCH)-create-kernel-package
	rm -rf $(KERNEL_PKGDIR)
	@mkdir -p $(KERNEL_PKGDIR)/boot
	cp $(KERNEL) $(KERNEL_PKGDIR)/boot/kernel
	@${BASH} ${SCRIPT_DIR}/make-ipkg-dir.sh ${KERNEL_PKGDIR} \
	    ../linux/kernel.control ${KERNEL_VERSION} ${CPU_ARCH}
	$(PKG_BUILD) $(KERNEL_PKGDIR) $(PACKAGE_DIR) $(MAKE_TRACE)
	$(TRACE) target/$(ADK_TARGET_ARCH)-install-kernel-package
	$(PKG_INSTALL) $(KERNEL_PKG) $(MAKE_TRACE)

ifeq ($(ADK_HARDWARE_QEMU),y)
TARGET_KERNEL=		${ADK_TARGET_SYSTEM}-$(CPU_ARCH)-${ADK_TARGET_FS}-kernel
INITRAMFS=		${ADK_TARGET_SYSTEM}-$(CPU_ARCH)-${ADK_TARGET_LIBC}-${ADK_TARGET_FS}
ROOTFSSQUASHFS=		${ADK_TARGET_SYSTEM}-$(CPU_ARCH)-${ADK_TARGET_LIBC}-${ADK_TARGET_FS}.img
ROOTFSJFFS2=		${ADK_TARGET_SYSTEM}-$(CPU_ARCH)-${ADK_TARGET_LIBC}-jffs2.img
ROOTFSTARBALL=		${ADK_TARGET_SYSTEM}-$(CPU_ARCH)-${ADK_TARGET_LIBC}-${ADK_TARGET_FS}+kernel.tar.gz
ROOTFSUSERTARBALL=	${ADK_TARGET_SYSTEM}-$(CPU_ARCH)-${ADK_TARGET_LIBC}-${ADK_TARGET_FS}.tar.gz
ROOTFSISO=		${ADK_TARGET_SYSTEM}-$(CPU_ARCH)-${ADK_TARGET_LIBC}-${ADK_TARGET_FS}.iso
else
TARGET_KERNEL=		${ADK_TARGET_SYSTEM}-${ADK_TARGET_FS}-kernel
INITRAMFS=		${ADK_TARGET_SYSTEM}-${ADK_TARGET_LIBC}-${ADK_TARGET_FS}
ROOTFSSQUASHFS=		${ADK_TARGET_SYSTEM}-${ADK_TARGET_LIBC}-${ADK_TARGET_FS}.img
ROOTFSJFFS2=		${ADK_TARGET_SYSTEM}-${ADK_TARGET_LIBC}-jffs2.img
ROOTFSTARBALL=		${ADK_TARGET_SYSTEM}-${ADK_TARGET_LIBC}-${ADK_TARGET_FS}+kernel.tar.gz
ROOTFSUSERTARBALL=	${ADK_TARGET_SYSTEM}-${ADK_TARGET_LIBC}-${ADK_TARGET_FS}.tar.gz
ROOTFSISO=		${ADK_TARGET_SYSTEM}-${ADK_TARGET_LIBC}-${ADK_TARGET_FS}.iso
endif

${BIN_DIR}/${ROOTFSTARBALL}: ${TARGET_DIR} kernel-package
	cd ${TARGET_DIR}; find . | sed -n '/^\.\//s///p' | \
		sed "s#\(.*\)#:0:0::::::\1#" | sort | \
		${TOOLS_DIR}/cpio -o -Hustar -P | gzip -n9 >$@

${BIN_DIR}/${ROOTFSUSERTARBALL}: ${TARGET_DIR}
	cd ${TARGET_DIR}; find . | grep -v ./boot/ | sed -n '/^\.\//s///p' | \
		sed "s#\(.*\)#:0:0::::::\1#" | sort | \
		${TOOLS_DIR}/cpio -o -Hustar -P | gzip -n9 >$@

${BIN_DIR}/${INITRAMFS}_list: ${TARGET_DIR}
	bash ${LINUX_DIR}/scripts/gen_initramfs_list.sh -u squash -g squash \
		${TARGET_DIR}/ >$@
	( \
		echo "nod /dev/console 0644 0 0 c 5 1"; \
		echo "nod /dev/tty 0644 0 0 c 5 0"; \
		for i in 0 1 2 3 4; do \
			echo "nod /dev/tty$$i 0644 0 0 c 4 $$$$i"; \
		done; \
		echo "nod /dev/systty 0644 0 0 c 4 0"; \
		echo "nod /dev/null 0644 0 0 c 1 3"; \
		echo "nod /dev/ram 0655 0 0 b 1 1"; \
	) >>$@

${BIN_DIR}/${INITRAMFS}: ${BIN_DIR}/${INITRAMFS}_list
	${LINUX_DIR}/usr/gen_init_cpio ${BIN_DIR}/${INITRAMFS}_list | \
		${ADK_COMPRESSION_TOOL} -c >$@

${BUILD_DIR}/root.squashfs: ${TARGET_DIR}
	${STAGING_HOST_DIR}/bin/mksquashfs ${TARGET_DIR} \
		${BUILD_DIR}/root.squashfs -comp xz \
		-nopad -noappend -root-owned $(MAKE_TRACE)

${BIN_DIR}/${ROOTFSJFFS2}: ${TARGET_DIR}
	${STAGING_HOST_DIR}/bin/mkfs.jffs2 $(ADK_JFFS2_OPTS) -q -r ${TARGET_DIR} \
		--pad=$(ADK_TARGET_MTD_SIZE) -o ${BIN_DIR}/${ROOTFSJFFS2} $(MAKE_TRACE)

createinitramfs: ${BIN_DIR}/${INITRAMFS}_list
	${SED} 's/.*CONFIG_(BLK_DEV_INITRD|INITRAMFS_SOURCE|INITRAMFS_COMPRESSION).*//' \
		${LINUX_DIR}/.config
	( \
		echo "CONFIG_BLK_DEV_INITRD=y"; \
		echo 'CONFIG_INITRAMFS_SOURCE="${BIN_DIR}/${INITRAMFS}_list"'; \
		echo '# CONFIG_INITRAMFS_COMPRESSION_NONE is not set' >> ${LINUX_DIR}/.config; \
		echo 'CONFIG_INITRAMFS_ROOT_UID=0' >> ${LINUX_DIR}/.config; \
		echo 'CONFIG_INITRAMFS_ROOT_GID=0' >> ${LINUX_DIR}/.config; \
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
	$(MAKE) -C $(LINUX_DIR) V=1 CROSS_COMPILE="$(TARGET_CROSS)" \
		ARCH=$(ARCH) CC="$(TARGET_CC)" -j${ADK_MAKE_JOBS} $(ADK_TARGET_KERNEL) $(MAKE_TRACE)

${BIN_DIR}/${ROOTFSISO}: ${TARGET_DIR} kernel-package
	mkdir -p ${TARGET_DIR}/boot/syslinux
	cp ${STAGING_HOST_DIR}/usr/share/syslinux/{isolinux.bin,ldlinux.c32} \
		${TARGET_DIR}/boot/syslinux
	echo 'DEFAULT /boot/kernel root=/dev/sr0 init=/init' > \
		${TARGET_DIR}/boot/syslinux/isolinux.cfg
	${TOOLS_DIR}/mkisofs -R -uid 0 -gid 0 -o $@ \
		-b boot/syslinux/isolinux.bin \
		-c boot/syslinux/boot.cat -no-emul-boot \
		-boot-load-size 4 -boot-info-table ${TARGET_DIR}

imageclean:
	rm -f $(BIN_DIR)/$(ADK_TARGET_SYSTEM)-* ${BUILD_DIR}/$(ADK_TARGET_SYSTEM)-*

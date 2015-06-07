# This file is part of the OpenADK project. OpenADK is copyrighted
# material, please see the LICENCE file in the top-level directory.

CP=			cp -fpR
INSTALL_DIR=		install -d -m0755
INSTALL_DATA=		install -m0644
INSTALL_BIN=		install -m0755
INSTALL_SCRIPT=		install -m0755
MAKEFLAGS=		$(EXTRA_MAKEFLAGS)
BUILD_USER=		$(shell id -un)
BUILD_GROUP=		$(shell id -gn)
ADK_SUFFIX:=		${ADK_TARGET_SYSTEM}_${ADK_TARGET_LIBC}_${ADK_TARGET_CPU_ARCH}
ifneq ($(ADK_TARGET_FLOAT),)
ADK_SUFFIX:=		$(ADK_SUFFIX)_$(ADK_TARGET_FLOAT)
endif
ifneq ($(ADK_TARGET_ABI),)
ADK_SUFFIX:=		$(ADK_SUFFIX)_$(ADK_TARGET_ABI)
endif
ifneq ($(ADK_TARGET_CPU_TYPE),)
ADK_SUFFIX:=		$(ADK_SUFFIX)_$(ADK_TARGET_CPU_TYPE)
endif
ifeq ($(ADK_TARGET_WITH_MMU),)
ADK_SUFFIX:=		$(ADK_SUFFIX)_nommu
endif

# some global dirs
BASE_DIR:=		$(ADK_TOPDIR)
ifeq ($(ADK_DL_DIR),)
DL_DIR?=		$(BASE_DIR)/dl
else
DL_DIR?=		$(ADK_DL_DIR)
endif
SCRIPT_DIR:=		$(BASE_DIR)/scripts
STAGING_HOST_DIR:=	${BASE_DIR}/host_${GNU_HOST_NAME}
HOST_BUILD_DIR:=	${BASE_DIR}/host_build_${GNU_HOST_NAME}
TOOLCHAIN_DIR:=		${BASE_DIR}/toolchain_${ADK_SUFFIX}

# dirs for cleandir
FW_DIR_PFX:=		$(BASE_DIR)/firmware
BUILD_DIR_PFX:=		$(BASE_DIR)/build_*
STAGING_PKG_DIR_PFX:=	${BASE_DIR}/pkg_*
STAGING_TARGET_DIR_PFX:=${BASE_DIR}/target_*
TOOLCHAIN_DIR_PFX=	$(BASE_DIR)/toolchain_*
STAGING_HOST_DIR_PFX:=	${BASE_DIR}/host_*
TARGET_DIR_PFX:=	$(BASE_DIR)/root_*

TARGET_DIR:=		$(BASE_DIR)/root_${ADK_SUFFIX}
FW_DIR:=		$(BASE_DIR)/firmware/${ADK_SUFFIX}
BUILD_DIR:=		${BASE_DIR}/build_${ADK_SUFFIX}
STAGING_TARGET_DIR:=	${BASE_DIR}/target_${ADK_SUFFIX}
STAGING_PKG_DIR:=	${BASE_DIR}/pkg_${ADK_SUFFIX}
STAGING_HOST2TARGET:=	../../target_${ADK_SUFFIX}
TOOLCHAIN_BUILD_DIR=	$(BASE_DIR)/toolchain_build_${ADK_SUFFIX}
PACKAGE_DIR:=		$(FW_DIR)/packages
SCRIPT_TARGET_DIR:=	${STAGING_TARGET_DIR}/scripts

# PATH variables
TARGET_PATH=		${SCRIPT_DIR}:${STAGING_TARGET_DIR}/scripts:${TOOLCHAIN_DIR}/usr/bin:${STAGING_HOST_DIR}/usr/bin:${_PATH}
HOST_PATH=		${SCRIPT_DIR}:${TOOLCHAIN_DIR}/usr/bin:${STAGING_HOST_DIR}/usr/bin:${_PATH}
AUTOTOOL_PATH=		${TOOLCHAIN_DIR}/usr/bin:${STAGING_HOST_DIR}/usr/bin:${STAGING_TARGET_DIR}/scripts:${_PATH}

ifeq ($(ADK_DISABLE_HONOUR_CFLAGS),)
GCC_CHECK:=		GCC_HONOUR_COPTS=2
else
GCC_CHECK:=
endif

ifeq ($(ADK_TARGET_UCLINUX),y)
ADK_TARGET_LINUXTYPE:=	uclinux
else
ADK_TARGET_LINUXTYPE:=	linux
endif

GNU_TARGET_NAME:=	$(ADK_TARGET_CPU_ARCH)-$(ADK_VENDOR)-$(ADK_TARGET_LINUXTYPE)-$(ADK_TARGET_SUFFIX)
ifeq ($(ADK_TARGET_ARCH_C6X),y)
GNU_TARGET_NAME:=	$(ADK_TARGET_CPU_ARCH)-$(ADK_TARGET_LINUXTYPE)
endif
TARGET_CROSS:=		$(TOOLCHAIN_DIR)/usr/bin/$(GNU_TARGET_NAME)-
TARGET_COMPILER_PREFIX?=${TARGET_CROSS}
CONFIGURE_TRIPLE:=	--build=${GNU_HOST_NAME} \
			--host=${GNU_TARGET_NAME} \
			--target=${GNU_TARGET_NAME}

ifneq ($(strip ${ADK_USE_CCACHE}),)
TARGET_COMPILER_PREFIX=$(STAGING_HOST_DIR)/usr/bin/ccache ${TARGET_CROSS}
endif

# target tools
TARGET_CC:=		${TARGET_COMPILER_PREFIX}gcc

# use a gcc wrapper for coldfire/arm uclinux support
ifeq ($(ADK_TARGET_UCLINUX),y)
ifeq ($(ADK_TARGET_ARCH_M68K),y)
TARGET_CC:=		adk-uclinux-gcc
endif
ifeq ($(ADK_TARGET_ARCH_ARM),y)
TARGET_CC:=		adk-uclinux-gcc
endif
endif

TARGET_CXX:=		${TARGET_COMPILER_PREFIX}g++
TARGET_LD:=		${TARGET_COMPILER_PREFIX}ld
TARGET_AR:=		${TARGET_COMPILER_PREFIX}ar
TARGET_RANLIB:=		${TARGET_COMPILER_PREFIX}ranlib

ifneq ($(ADK_TARGET_ABI_CFLAGS),)
TARGET_CC+=		$(ADK_TARGET_ABI_CFLAGS)
TARGET_CXX+=		$(ADK_TARGET_ABI_CFLAGS)
endif

TARGET_CPPFLAGS:=	
TARGET_CFLAGS:=		-fwrapv -fno-ident
TARGET_CXXFLAGS:=	-fwrapv -fno-ident
TARGET_LDFLAGS:=	-L$(STAGING_TARGET_DIR)/lib -L$(STAGING_TARGET_DIR)/usr/lib \
			-Wl,-O1 -Wl,-rpath -Wl,/usr/lib \
			-Wl,-rpath-link -Wl,${STAGING_TARGET_DIR}/usr/lib

ifeq ($(ADK_DISABLE_HONOUR_CFLAGS),)
TARGET_CFLAGS+=		-fhonour-copts
TARGET_CXXFLAGS+=	-fhonour-copts
endif

# for architectures where gcc --with-cpu matches -mcpu=
ifneq ($(ADK_TARGET_GCC_CPU),)
ifeq ($(ADK_CPU_ARC700),y)
TARGET_CFLAGS+=		-mcpu=ARC700
TARGET_CXXFLAGS+=	-mcpu=ARC700
else
TARGET_CFLAGS+=		-mcpu=$(ADK_TARGET_GCC_CPU)
TARGET_CXXFLAGS+=	-mcpu=$(ADK_TARGET_GCC_CPU)
endif
endif

# for archiectures where gcc --with-arch matches -march=
ifneq ($(ADK_TARGET_GCC_ARCH),)
TARGET_CFLAGS+=		-march=$(ADK_TARGET_GCC_ARCH)
TARGET_CXXFLAGS+=	-march=$(ADK_TARGET_GCC_ARCH)
endif

ifneq ($(ADK_TARGET_CPU_FLAGS),)
TARGET_CFLAGS+=		$(ADK_TARGET_CPU_FLAGS)
TARGET_CXXFLAGS+=	$(ADK_TARGET_CPU_FLAGS)
endif

ifneq ($(ADK_TARGET_FPU),)
TARGET_CFLAGS+=		-mfpu=$(ADK_TARGET_FPU)
TARGET_CXXFLAGS+=	-mfpu=$(ADK_TARGET_FPU)
endif

ifneq ($(ADK_TARGET_FLOAT),)
ifeq ($(ADK_TARGET_ARCH_ARM),y)
TARGET_CFLAGS+=		-mfloat-abi=$(ADK_TARGET_FLOAT)
TARGET_CXXFLAGS+=	-mfloat-abi=$(ADK_TARGET_FLOAT)
endif
ifeq ($(ADK_TARGET_ARCH_MIPS),y)
TARGET_CFLAGS+=		-m$(ADK_TARGET_FLOAT)-float
TARGET_CXXFLAGS+=	-m$(ADK_TARGET_FLOAT)-float
endif
endif

ifeq ($(ADK_TARGET_ARCH_ARM),y)
ifeq ($(ADK_TARGET_BINFMT_FLAT),y)
TARGET_CFLAGS+=		-Wl,-elf2flt
TARGET_CXXFLAGS+=	-Wl,-elf2flt
endif
endif

ifeq ($(ADK_TARGET_ARCH_BFIN),y)
ifeq ($(ADK_TARGET_BINFMT_FLAT),y)
TARGET_LDFLAGS+=	-elf2flt
endif
ifeq ($(ADK_TARGET_BINFMT_FLAT_SEP_DATA),y)
TARGET_CFLAGS+=		-msep-data
TARGET_CXXFLAGS+=	-msep-data
endif
endif

ifeq ($(ADK_TARGET_ARCH_M68K),y)
ifeq ($(ADK_TARGET_BINFMT_FLAT),y)
TARGET_LDFLAGS+=	-elf2flt
endif
ifeq ($(ADK_TARGET_BINFMT_FLAT_SEP_DATA),y)
TARGET_CFLAGS+=		-msep-data
TARGET_CXXFLAGS+=	-msep-data
endif
endif

ifeq ($(ADK_TARGET_LIB_MUSL),y)
# use -static-libgcc by default only for musl
TARGET_CFLAGS+=		-static-libgcc
TARGET_CXXFLAGS+=	-static-libgcc
TARGET_LDFLAGS+=	-static-libgcc
endif

# security optimization, see http://www.akkadia.org/drepper/dsohowto.pdf
ifneq ($(ADK_TARGET_USE_LD_RELRO),)
TARGET_LDFLAGS+=	-Wl,-z,relro
endif
ifneq ($(ADK_TARGET_USE_LD_BIND_NOW),)
TARGET_LDFLAGS+=	-Wl,-z,now
endif

# needed for musl ppc 
ifeq ($(ADK_TARGET_ARCH_PPC),y)
ifeq ($(ADK_TARGET_LIB_MUSL),y)
TARGET_LDFLAGS+=	-Wl,--secure-plt
endif
endif

ifeq ($(ADK_TARGET_USE_STATIC_LIBS),y)
TARGET_CFLAGS+=		-static
TARGET_CXXFLAGS+=	-static
TARGET_LDFLAGS+=	-static
endif

ifneq ($(ADK_TARGET_USE_SSP),)
TARGET_CFLAGS+=		-fstack-protector-all --param=ssp-buffer-size=4
TARGET_CXXFLAGS+=	-fstack-protector-all --param=ssp-buffer-size=4
TARGET_LDFLAGS+=	-fstack-protector-all
endif

ifneq ($(ADK_TARGET_USE_LD_GC),)
TARGET_CFLAGS+=		-fdata-sections -ffunction-sections
TARGET_CXXFLAGS+=	-fdata-sections -ffunction-sections
TARGET_LDFLAGS+=	-Wl,--gc-sections
endif

ifneq ($(ADK_TARGET_USE_LTO),)
TARGET_CFLAGS+=		-flto
TARGET_CXXFLAGS+=	-flto
TARGET_LDFLAGS+=	-flto
endif

# performance optimization, see http://www.akkadia.org/drepper/dsohowto.pdf
ifneq ($(ADK_TARGET_USE_GNU_HASHSTYLE),)
TARGET_LDFLAGS+=	-Wl,--hash-style=gnu
endif

ifeq ($(ADK_TARGET_ARCH_MICROBLAZE),y)
TARGET_CFLAGS+=		-mxl-barrel-shift
TARGET_CXXFLAGS+=	-mxl-barrel-shift
endif
ifeq ($(ADK_TARGET_ARCH_XTENSA),y)
TARGET_CFLAGS+=		-mlongcalls -mtext-section-literals
TARGET_CXXFLAGS+=	-mlongcalls -mtext-section-literals
endif

# add configured compiler flags for optimization
TARGET_CFLAGS+=		$(ADK_TARGET_CFLAGS_OPT)
TARGET_CXXFLAGS+=	$(ADK_TARGET_CFLAGS_OPT)

# add compiler flags for debug information
ifeq ($(ADK_BUILD_WITH_DEBUG),y)
TARGET_CFLAGS+=		-g3
TARGET_CXXFLAGS+=	-g3
endif

ifneq ($(ADK_DEBUG),)
TARGET_CFLAGS+=		-fno-omit-frame-pointer
TARGET_CXXFLAGS+=	-fno-omit-frame-pointer
TARGET_CFLAGS+=		-funwind-tables -fasynchronous-unwind-tables
TARGET_CXXFLAGS+=	-funwind-tables -fasynchronous-unwind-tables
else
TARGET_CPPFLAGS+=	-DNDEBUG
TARGET_CFLAGS+=		-fomit-frame-pointer
TARGET_CXXFLAGS+=	-fomit-frame-pointer
# stop generating eh_frame stuff
TARGET_CFLAGS+=		-fno-unwind-tables -fno-asynchronous-unwind-tables
TARGET_CXXFLAGS+=	-fno-unwind-tables -fno-asynchronous-unwind-tables
endif

ifeq ($(ADK_TARGET_ARCH_ARM),y)
ifeq ($(ADK_TARGET_ARCH_ARM_WITH_NEON),y)
TARGET_CFLAGS+=		-funsafe-math-optimizations
TARGET_CXXFLAGS+=	-funsafe-math-optimizations
endif
ifeq ($(ADK_TARGET_ARCH_ARM_WITH_THUMB),y)
TARGET_CFLAGS+=		-mthumb -Wa,-mimplicit-it=thumb
TARGET_CXXFLAGS+=	-mthumb -Wa,-mimplicit-it=thumb
else
TARGET_CFLAGS+=		-marm
TARGET_CXXFLAGS+=	-marm
endif
endif

# host compiler and linker flags
HOST_CPPFLAGS:=		-I$(STAGING_HOST_DIR)/usr/include
HOST_LDFLAGS:=		-L$(STAGING_HOST_DIR)/usr/lib -Wl,-rpath -Wl,${STAGING_HOST_DIR}/usr/lib

PATCH=			PATH='${HOST_PATH}' ${BASH} $(SCRIPT_DIR)/patch.sh
PATCHP0=		PATH='${HOST_PATH}' patch -p0

ifeq ($(ADK_STATIC_TOOLCHAIN),y)
HOST_STATIC_CFLAGS:=   -static -Wl,-static
HOST_STATIC_CXXFLAGS:= -static -Wl,-static
HOST_STATIC_LDFLAGS:=  -Wl,-static
HOST_STATIC_LLDFLAGS:= -all-static
endif

SED:=			PATH='${HOST_PATH}' sed -i -e
XZ:=			PATH='${HOST_PATH}' xz
LINUX_DIR:=		$(BUILD_DIR)/linux
KERNEL_MODULE_FLAGS:=	ARCH=${ADK_TARGET_ARCH} \
			PREFIX=/usr \
			KERNEL_PATH=${LINUX_DIR} \
			KERNELDIR=${LINUX_DIR} \
			KERNEL_DIR=${LINUX_DIR} \
			CROSS_COMPILE="${TARGET_CROSS}" \
			CFLAGS_MODULE="-fhonour-copts" \
			V=1

COMMON_ENV=		CONFIG_SHELL='$(strip ${SHELL})' \
			AUTOM4TE='${STAGING_HOST_DIR}/usr/bin/autom4te' \
			M4='${STAGING_HOST_DIR}/usr/bin/m4' \
			LIBTOOLIZE='${STAGING_HOST_DIR}/usr/bin/libtoolize -q' \
			VERBOSE=1
			
TARGET_ENV=		AR='$(TARGET_CROSS)ar' \
			AS='$(TARGET_CROSS)as' \
			LD='$(TARGET_CROSS)ld' \
			NM='$(TARGET_CROSS)nm' \
			RANLIB='$(TARGET_CROSS)ranlib' \
			STRIP='$(TARGET_CROSS)strip' \
			OBJCOPY='$(TARGET_CROSS)objcopy' \
			CC='$(TARGET_CC)' \
			GCC='$(TARGET_CC)' \
			CXX='$(TARGET_CXX)' \
			CROSS='$(TARGET_CROSS)' \
			CROSS_COMPILE='$(TARGET_CROSS)' \
			CFLAGS='$(TARGET_CFLAGS)' \
			CXXFLAGS='$(TARGET_CXXFLAGS)' \
			CPPFLAGS='$(TARGET_CPPFLAGS)' \
			LDFLAGS='$(TARGET_LDFLAGS)' \
			CC_FOR_BUILD='$(HOST_CC)' \
			CXX_FOR_BUILD='$(HOST_CXX)' \
			CPPFLAGS_FOR_BUILD='$(HOST_CPPFLAGS)' \
			CFLAGS_FOR_BUILD='$(HOST_CFLAGS)' \
			CXXFLAGS_FOR_BUILD='$(HOST_CXXFLAGS)' \
			LDFLAGS_FOR_BUILD='$(HOST_LDFLAGS)' \
			LIBS_FOR_BUILD='$(HOST_LIBS)'

HOST_ENV=		CC='$(HOST_CC)' \
			CXX='$(HOST_CXX)' \
			CPPFLAGS='$(HOST_CPPFLAGS)' \
			CFLAGS='$(HOST_CFLAGS)' \
			CXXFLAGS='$(HOST_CXXFLAGS)' \
			LDFLAGS='$(HOST_LDFLAGS)'

PKG_SUFFIX:=		$(strip $(subst ",, $(ADK_PACKAGE_SUFFIX)))

ifeq ($(ADK_TARGET_PACKAGE_IPKG),y)
PKG_BUILD:=		PATH='${HOST_PATH}' \
			${BASH} ${SCRIPT_DIR}/ipkg-build
PKG_INSTALL:=		PATH='${HOST_PATH}' \
			IPKG_TMP=$(BUILD_DIR)/tmp \
			IPKG_INSTROOT=$(TARGET_DIR) \
			IPKG_CONF_DIR=$(STAGING_TARGET_DIR)/etc \
			IPKG_OFFLINE_ROOT=$(TARGET_DIR) \
			BIN_DIR=$(STAGING_HOST_DIR)/usr/bin \
			${BASH} ${SCRIPT_DIR}/ipkg \
			-force-defaults -force-depends install
PKG_STATE_DIR:=		$(TARGET_DIR)/usr/lib/ipkg
endif

ifeq ($(ADK_TARGET_PACKAGE_OPKG),y)
PKG_BUILD:=		PATH='${HOST_PATH}' \
			${BASH} ${SCRIPT_DIR}/ipkg-build
PKG_INSTALL:=		PATH='${HOST_PATH}' \
			IPKG_TMP=$(BUILD_DIR)/tmp \
			IPKG_INSTROOT=$(TARGET_DIR) \
			IPKG_CONF_DIR=$(STAGING_TARGET_DIR)/etc \
			IPKG_OFFLINE_ROOT=$(TARGET_DIR) \
			BIN_DIR=$(STAGING_HOST_DIR)/usr/bin \
			${BASH} ${SCRIPT_DIR}/ipkg \
			-force-defaults -force-depends install
PKG_STATE_DIR:=		$(TARGET_DIR)/usr/lib/opkg
endif

ifeq ($(ADK_TARGET_PACKAGE_TXZ),y)
PKG_BUILD:=		PATH='${HOST_PATH}' ${BASH} ${SCRIPT_DIR}/tarpkg build
PKG_INSTALL:=		PKG_INSTROOT='$(TARGET_DIR)' \
			PATH='${HOST_PATH}' ${BASH} ${SCRIPT_DIR}/tarpkg install
PKG_STATE_DIR:=		$(TARGET_DIR)/usr/lib/pkg
endif

RSTRIP:=		PATH="$(TARGET_PATH)" prefix='${TARGET_CROSS}' ${BASH} ${SCRIPT_DIR}/rstrip.sh

STATCMD:=$(shell if stat -qs .>/dev/null 2>&1; then echo 'stat -f %z';else echo 'stat -c %s';fi)
	
EXTRACT_CMD=		PATH='${HOST_PATH}'; mkdir -p ${WRKDIR}; \
			cd ${WRKDIR} && \
			for file in ${FULLDISTFILES}; do case $$file in \
			*.cpio) \
				cat $$file | cpio -i -d ;; \
			*.tar) \
				tar -xf $$file ;; \
			*.cpio.Z | *.cpio.gz | *.cgz | *.mcz) \
				gzip -dc $$file | cpio -i -d ;; \
			*.tar.xz | *.txz) \
				xz -dc $$file | tar -xf - ;; \
			*.tar.Z | *.tar.gz | *.taz | *.tgz) \
				gzip -dc $$file | tar -xf - ;; \
			*.cpio.bz2 | *.cbz) \
				bzip2 -dc $$file | cpio -i -d ;; \
			*.tar.bz2 | *.tbz | *.tbz2) \
				bzip2 -dc $$file | tar -xf - ;; \
			*.zip) \
				cat $$file | cpio -id -H zip ;; \
			*.arm|*.jar|*.ids.gz) \
				mkdir ${WRKBUILD}; cp $$file ${WRKBUILD} ;; \
			*.bin) \
				sh $$file --force --auto-accept ;; \
			*) \
				echo "Cannot extract '$$file'" >&2; \
				false ;; \
			esac; done

ifeq ($(ADK_VERBOSE),1)
QUIET:=
else
QUIET:=			--quiet
endif
FETCH_CMD?=		PATH='${HOST_PATH}' wget --timeout=$(ADK_WGET_TIMEOUT) -t 3 --no-check-certificate $(QUIET)

ifneq (,$(filter CYGWIN%,${OStype}))
EXEEXT:=		.exe
endif

include $(ADK_TOPDIR)/mk/mirrors.mk

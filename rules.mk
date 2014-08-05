# This file is part of the OpenADK project. OpenADK is copyrighted
# material, please see the LICENCE file in the top-level directory.

include $(ADK_TOPDIR)/prereq.mk
-include $(ADK_TOPDIR)/.config

ifeq ($(VERBOSE),1)
START_TRACE:=		:
END_TRACE:=		:
TRACE:=			:
CMD_TRACE:=		:
PKG_TRACE:=		:
MAKE_TRACE:=
EXTRA_MAKEFLAGS:=
SET_DASHX:=		set -x
else
START_TRACE:=		echo -n "---> "
END_TRACE:=		echo
TRACE:=			echo "---> "
CMD_TRACE:=		echo -n
PKG_TRACE:=		echo "------> "
EXTRA_MAKEFLAGS:=	-s
MAKE_TRACE:=		>/dev/null 2>&1 || { echo "Build failed. Please re-run make with v to see what's going on"; false; }
SET_DASHX:=		:
endif

# Strip off the annoying quoting
ADK_TARGET_ARCH:=			$(strip $(subst ",, $(ADK_TARGET_ARCH)))
ADK_TARGET_SYSTEM:=			$(strip $(subst ",, $(ADK_TARGET_SYSTEM)))
ADK_TARGET_CPU_ARCH:=			$(strip $(subst ",, $(ADK_TARGET_CPU_ARCH)))
ADK_TARGET_KERNEL:=			$(strip $(subst ",, $(ADK_TARGET_KERNEL)))
ADK_TARGET_LIBC:=			$(strip $(subst ",, $(ADK_TARGET_LIBC)))
ADK_TARGET_LIBC_PATH:=			$(strip $(subst ",, $(ADK_TARGET_LIBC_PATH)))
ADK_TARGET_ENDIAN:=			$(strip $(subst ",, $(ADK_TARGET_ENDIAN)))
ADK_TARGET_FLOAT:=			$(strip $(subst ",, $(ADK_TARGET_FLOAT)))
ADK_TARGET_FPU:=			$(strip $(subst ",, $(ADK_TARGET_FPU)))
ADK_TARGET_ARM_MODE:=			$(strip $(subst ",, $(ADK_TARGET_ARM_MODE)))
ADK_TARGET_CFLAGS:=			$(strip $(subst ",, $(ADK_TARGET_CFLAGS)))
ADK_TARGET_CFLAGS_OPT:=			$(strip $(subst ",, $(ADK_TARGET_CFLAGS_OPT)))
ADK_TARGET_ABI_CFLAGS:=			$(strip $(subst ",, $(ADK_TARGET_ABI_CFLAGS)))
ADK_TARGET_ABI:=			$(strip $(subst ",, $(ADK_TARGET_ABI)))
ADK_TARGET_MIPS_ABI:=			$(strip $(subst ",, $(ADK_TARGET_MIPS_ABI)))
ADK_TARGET_IP:=				$(strip $(subst ",, $(ADK_TARGET_IP)))
ADK_TARGET_SUFFIX:=			$(strip $(subst ",, $(ADK_TARGET_SUFFIX)))
ADK_TARGET_CMDLINE:=			$(strip $(subst ",, $(ADK_TARGET_CMDLINE)))
ADK_QEMU_ARGS:=				$(strip $(subst ",, $(ADK_QEMU_ARGS)))
ADK_RUNTIME_TMPFS_SIZE:=		$(strip $(subst ",, $(ADK_RUNTIME_TMPFS_SIZE)))
ADK_RUNTIME_CONSOLE_SERIAL_SPEED:=	$(strip $(subst ",, $(ADK_RUNTIME_CONSOLE_SERIAL_SPEED)))
ADK_RUNTIME_CONSOLE_SERIAL_DEVICE:=	$(strip $(subst ",, $(ADK_RUNTIME_CONSOLE_SERIAL_DEVICE)))
ADK_HOST:=				$(strip $(subst ",, $(ADK_HOST)))
ADK_VENDOR:=				$(strip $(subst ",, $(ADK_VENDOR)))
ADK_DL_DIR:=				$(strip $(subst ",, $(ADK_DL_DIR)))
ADK_COMPRESSION_TOOL:=			$(strip $(subst ",, $(ADK_COMPRESSION_TOOL)))
ADK_KERNEL_VERSION:=			$(strip $(subst ",, $(ADK_KERNEL_VERSION)))
ADK_LIBC_VERSION:=			$(strip $(subst ",, $(ADK_LIBC_VERSION)))
ADK_PARAMETER_NETCONSOLE_SRC_IP:=	$(strip $(subst ",, $(ADK_PARAMETER_NETCONSOLE_SRC_IP)))
ADK_PARAMETER_NETCONSOLE_DST_IP:=	$(strip $(subst ",, $(ADK_PARAMETER_NETCONSOLE_DST_IP)))
ADK_JFFS2_OPTS:=			$(strip $(subst ",, $(ADK_JFFS2_OPTS)))
ADK_WGET_TIMEOUT:=			$(strip $(subst ",, $(ADK_WGET_TIMEOUT)))

ADK_TARGET_KARCH:=$(ADK_TARGET_ARCH)

# translate toolchain arch to kernel arch
ifeq ($(ADK_TARGET_ARCH),aarch64)
ADK_TARGET_KARCH:=arm64
endif
ifeq ($(ADK_TARGET_ARCH),ppc)
ADK_TARGET_KARCH:=powerpc
endif
ifeq ($(ADK_TARGET_ARCH),ppc64)
ADK_TARGET_KARCH:=powerpc
endif
ifeq ($(ADK_TARGET_ARCH),mips64)
ADK_TARGET_KARCH:=mips
endif

include $(ADK_TOPDIR)/mk/vars.mk

ifneq (${show},)
.DEFAULT_GOAL:=		show
show:
	@$(info ${${show}})
else ifneq (${dump},)
__shquote=		'$(subst ','\'',$(1))'
__dumpvar=		echo $(call __shquote,$(1)=$(call __shquote,${$(1)}))
.DEFAULT_GOAL:=		show
show:
	@$(foreach _s,${dump},$(call __dumpvar,${_s});)
endif

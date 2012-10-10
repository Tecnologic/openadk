# This file is part of the OpenADK project. OpenADK is copyrighted
# material, please see the LICENCE file in the top-level directory.

include $(TOPDIR)/prereq.mk
-include $(TOPDIR)/.config

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
ADK_TARGET_ARCH:=	$(strip $(subst ",, $(ADK_TARGET_ARCH)))
ADK_TARGET_SYSTEM:=	$(strip $(subst ",, $(ADK_TARGET_SYSTEM)))
ADK_TARGET_LIBC:=	$(strip $(subst ",, $(ADK_TARGET_LIBC)))
ADK_TARGET_LIBC_PATH:=	$(strip $(subst ",, $(ADK_TARGET_LIBC_PATH)))
ADK_TARGET_ENDIAN:=	$(strip $(subst ",, $(ADK_TARGET_ENDIAN)))
ADK_TARGET_CPU_ARCH:=	$(strip $(subst ",, $(ADK_TARGET_CPU_ARCH)))
ADK_TARGET_CFLAGS:=	$(strip $(subst ",, $(ADK_TARGET_CFLAGS)))
ADK_TARGET_ABI_CFLAGS:=	$(strip $(subst ",, $(ADK_TARGET_ABI_CFLAGS)))
ADK_TARGET_ABI_LDFLAGS:=	$(strip $(subst ",, $(ADK_TARGET_ABI_LDFLAGS)))
ADK_TARGET_KERNEL_LDFLAGS:=	$(strip $(subst ",, $(ADK_TARGET_KERNEL_LDFLAGS)))
ADK_TARGET_ABI:=	$(strip $(subst ",, $(ADK_TARGET_ABI)))
ADK_TARGET_IP:=		$(strip $(subst ",, $(ADK_TARGET_IP)))
ADK_TARGET_SUFFIX:=	$(strip $(subst ",, $(ADK_TARGET_SUFFIX)))
ADK_TARGET_CMDLINE:=	$(strip $(subst ",, $(ADK_TARGET_CMDLINE)))
ADK_RUNTIME_TMPFS_SIZE:=	$(strip $(subst ",, $(ADK_RUNTIME_TMPFS_SIZE)))
ADK_RUNTIME_CONSOLE_SERIAL_SPEED:=	$(strip $(subst ",, $(ADK_RUNTIME_CONSOLE_SERIAL_SPEED)))
ADK_HOST:=		$(strip $(subst ",, $(ADK_HOST)))
ADK_VENDOR:=		$(strip $(subst ",, $(ADK_VENDOR)))
ADK_TOOLS_ADDPATTERN_ARGS:=	$(strip $(subst ",, $(ADK_TOOLS_ADDPATTERN_ARGS)))
ADK_KERNEL_VERSION:=		$(strip $(subst ",, $(ADK_KERNEL_VERSION)))
ADK_PARAMETER_NETCONSOLE_SRC_IP:=	$(strip $(subst ",, $(ADK_PARAMETER_NETCONSOLE_SRC_IP)))
ADK_PARAMETER_NETCONSOLE_DST_IP:=	$(strip $(subst ",, $(ADK_PARAMETER_NETCONSOLE_DST_IP)))

ifeq ($(strip ${ADK_HAVE_DOT_CONFIG}),y)
ifneq ($(strip $(wildcard $(TOPDIR)/target/$(ADK_TARGET_ARCH)/target.mk)),)
include $(TOPDIR)/target/$(ADK_TARGET_ARCH)/target.mk
endif
endif

ifneq (${DEBUG},)
ADK_DEBUG:=y
endif
ifneq (${STATIC},)
ADK_STATIC:=y
endif

include $(TOPDIR)/mk/vars.mk

CPPFLAGS_FOR_BUILD?=
CFLAGS_FOR_BUILD?=	-O2 -Wall
CXXFLAGS_FOR_BUILD?=	-O2 -Wall
LDFLAGS_FOR_BUILD?=
FLAGS_FOR_BUILD:=	${CPPFLAGS_FOR_BUILD} ${CFLAGS_FOR_BUILD} ${LDFLAGS_FOR_BUILD}

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

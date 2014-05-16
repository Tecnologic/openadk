ifeq ($(ADK_KERNEL_VERSION_TOOLCHAIN),y)
KERNEL_VERSION:=	3.14.4
KERNEL_MOD_VERSION:=	$(KERNEL_VERSION)
KERNEL_RELEASE:=	1
KERNEL_MD5SUM:=		c7c565d14833550faa39ef8279272182
endif
ifeq ($(ADK_KERNEL_VERSION_3_15_RC5),y)
KERNEL_VERSION:=	3.15-rc5
KERNEL_MOD_VERSION:=	3.15.0-rc5
KERNEL_RELEASE:=	1
KERNEL_MD5SUM:=		b030ddc3f1581c4675c31e51f3551089
endif
ifeq ($(ADK_KERNEL_VERSION_3_14_4),y)
KERNEL_VERSION:=	3.14.4
KERNEL_MOD_VERSION:=	$(KERNEL_VERSION)
KERNEL_RELEASE:=	1
KERNEL_MD5SUM:=		c7c565d14833550faa39ef8279272182
endif
ifeq ($(ADK_KERNEL_VERSION_3_13_11),y)
KERNEL_VERSION:=	3.13.11
KERNEL_MOD_VERSION:=	$(KERNEL_VERSION)
KERNEL_RELEASE:=	1
KERNEL_MD5SUM:=		d4e06af8b674ac74ba745d52e4382bd3
endif
ifeq ($(ADK_KERNEL_VERSION_3_12_18),y)
KERNEL_VERSION:=	3.12.18
KERNEL_MOD_VERSION:=	$(KERNEL_VERSION)
KERNEL_RELEASE:=	1
KERNEL_MD5SUM:=		ec32bc59a5feb46c74adb1df7d3e3e98
endif
ifeq ($(ADK_KERNEL_VERSION_3_11_10),y)
KERNEL_VERSION:=	3.11.10
KERNEL_MOD_VERSION:=	$(KERNEL_VERSION)
KERNEL_RELEASE:=	1
KERNEL_MD5SUM:=		59f352d3f4e2cdf6755f79e09fa09176
endif
ifeq ($(ADK_KERNEL_VERSION_3_10_37),y)
KERNEL_VERSION:=	3.10.37
KERNEL_MOD_VERSION:=	$(KERNEL_VERSION)
KERNEL_RELEASE:=	1
KERNEL_MD5SUM:=		a08a10ffc31b07d9422af1cd2baa3274
endif
ifeq ($(ADK_KERNEL_VERSION_3_10_30),y)
KERNEL_VERSION:=	3.10.30
KERNEL_MOD_VERSION:=	$(KERNEL_VERSION)
KERNEL_RELEASE:=	1
KERNEL_MD5SUM:=		f48ca7dd9f2eb14a2903cb6a4fbe07ed
endif
ifeq ($(ADK_KERNEL_VERSION_3_4_87),y)
KERNEL_VERSION:=	3.4.87
KERNEL_MOD_VERSION:=	$(KERNEL_VERSION)
KERNEL_RELEASE:=	1
KERNEL_MD5SUM:=		f926dc8c57400f57aec407106632de0b
endif

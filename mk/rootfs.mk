# This file is part of the OpenADK project. OpenADK is copyrighted
# material, please see the LICENCE file in the top-level directory.

define rootfs_template
ifeq ($(ADK_TARGET_ROOTFS_$(2)),y)
FS:=$(1)
FS_CMDLINE:=$(3)
endif
endef

ADK_TARGET_ROOTFS_USB_DEVICE:=$(strip $(subst ",, $(ADK_TARGET_ROOTFS_USB_DEVICE)))

ifeq ($(ADK_LINUX_MIPS_RB532),y)
ROOTFS:=	root=/dev/sda2
MTDDEV:=	root=/dev/mtdblock1
endif

ifeq ($(ADK_LINUX_MIPS_RB433),y)
MTDDEV:=	root=/dev/mtdblock2
endif

ifeq ($(ADK_LINUX_ARM_FOXG20),y)
ROOTFS:=	root=/dev/mmcblk0p2 rootwait
endif

$(eval $(call rootfs_template,ext2-block,EXT2_BLOCK,$(ROOTFS)))
$(eval $(call rootfs_template,usb,USB,root=$(ADK_TARGET_ROOTFS_USB_DEVICE) rootdelay=3))
$(eval $(call rootfs_template,archive,ARCHIVE))
$(eval $(call rootfs_template,initramfs,INITRAMFS))
$(eval $(call rootfs_template,initramfs-piggyback,INITRAMFS_PIGGYBACK))
$(eval $(call rootfs_template,squashfs,SQUASHFS))
$(eval $(call rootfs_template,yaffs,YAFFS,$(MTDDEV) panic=3))
$(eval $(call rootfs_template,nfsroot,NFSROOT,root=/dev/nfs ip=dhcp init=/init))
$(eval $(call rootfs_template,encrypted,ENCRYPTED))

export FS

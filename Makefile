# This file is part of the OpenADK project. OpenADK is copyrighted
# material, please see the LICENCE file in the top-level directory.

_UNLIMIT=	__limit=$$(ulimit -dH 2>/dev/null); \
		test -n "$$__limit" && ulimit -dS $$__limit;

all: checkreloc .prereq_done
	@${_UNLIMIT} ${GMAKE_INV} all

v: .prereq_done
	@(echo; echo "Build started on $$(LC_ALL=C LANGUAGE=C date)"; \
	    set -x; ${_UNLIMIT} ${GMAKE_FMK} VERBOSE=1 all) 2>&1 | tee -a make.log

help:
	@echo 'Configuration targets:'
	@echo '  config       - Update current config utilising a line-oriented program'
	@echo '  menuconfig   - Update current config utilising a menu based program'
	@echo '                 (default when .config does not exist)'
	@echo '  guiconfig    - Update current config utilising a gui based program'
	@echo '  oldconfig    - Update current config utilising a provided .configs base'
	@echo '  allmodconfig - New config selecting all packages as modules when possible'
	@echo '  allconfig    - New config selecting all packages when possible'
	@echo '  allnoconfig  - New config where all options are answered with no'
	@echo ''
	@echo 'Help targets:'
	@echo '  help         - Print this help text'
	@echo '  pkg-help     - Print help about selectively compiling single packages'
	@echo '  dev-help     - Print help for developers / package maintainers'
	@echo ''
	@echo 'Common targets:'
	@echo '  switch ARCH=arch SYSTEM=system - Backup current config and copy old saved target config'
	@echo '  download     - fetches all needed distfiles'
	@echo '  kernelconfig - Modify the target kernel configuration'
	@echo ''
	@echo 'Cleaning targets:'
	@echo '  clean        - Remove bin and build_dir directories'
	@echo '  cleantarget  - Same as "clean", but also remove toolchain for target'
	@echo '  cleandir     - Same as "clean", but also remove all built toolchains'
	@echo '  cleankernel  - Remove kernel dir, useful if you changed any kernel patches'
	@echo '  distclean    - Same as "cleandir", but also remove downloaded'
	@echo '                 distfiles and .config'
	@echo ''
	@echo 'Other generic targets:'
	@echo '  all          - Build everything as specified in .config'
	@echo '                 (default if .config exists)'
	@echo '  v            - Same as "all" but with logging to make.log enabled'

pkg-help:
	@echo 'Package specific targets (use with "package=<pkg-name>" parameter):'
	@echo '  fetch        - Download the necessary distfile'
	@echo '  extract      - Same as "fetch", but also extract the distfile'
	@echo '  patch        - Same as "extract", but also patch the source'
	@echo '  build        - Same as "patch", but also build the binaries'
	@echo '  fake         - Same as "build", but also install the binaries'
	@echo '  package      - Same as "fake", but also create the package'
	@echo '  clean        - Deinstall and remove the build area'
	@echo '  distclean    - Same as "clean", but also remove the distfiles'
	@echo ''
	@echo 'Short package rebuilding guide:'
	@echo '  run "make package=<pkgname> clean" to remove all generated binaries'
	@echo '  run "make package=<pkgname> package" to build everything and create the package(s)'
	@echo ''
	@echo 'This does not automatically resolve package dependencies!'

dev-help:
	@echo 'Fast way of updating package patches:'
	@echo '  run "make package=<pkgname> clean" to start with a good base'
	@echo '  run "make package=<pkgname> patch" to fetch, unpack and patch the source'
	@echo '  edit the package sources at build_dir/w-<pkgname>-*/<pkgname>-<version>'
	@echo '  run "make package=<pkgname> update-patches" to regenerate patch files'
	@echo ''
	@echo 'All changed patches will be opened with your $$EDITOR,'
	@echo 'so you can add a description and verify the modifications.'
	@echo ''
	@echo 'Adding a new package:'
	@echo 'make PKG=foo VER=1.0 newpackage'

clean: .prereq_done
	-@rm -f nohup.out
	@${GMAKE_INV} clean

config: .prereq_done
	@${GMAKE_INV} _config W=

oldconfig: .prereq_done
	@${GMAKE_INV} _config W=-o

download: .prereq_done
	@${GMAKE_INV} toolchain/download
	@${GMAKE_INV} package/download

cleankernel kernelclean: .prereq_done
	-@${GMAKE_INV} cleankernel

cleandir dirclean: .prereq_done
	-@${GMAKE_INV} cleandir
	@-rm -f make.log .prereq_done

cleantarget targetclean: .prereq_done
	-@${GMAKE_INV} cleantarget
	@-rm -f make.log

distclean cleandist:
	-@${GMAKE_INV} distclean
	@-rm -f make.log .prereq_done

image: .prereq_done
	@${GMAKE_INV} image

switch: .prereq_done
	@${GMAKE_INV} switch

kernelconfig: .prereq_done
	@${GMAKE_INV} kernelconfig

newpackage: .prereq_done
	@${GMAKE_INV} newpackage

image_clean imageclean cleanimage: .prereq_done
	@${GMAKE_INV} image_clean

menuconfig: .prereq_done
	@${GMAKE_INV} menuconfig

guiconfig: .prereq_done
	@${GMAKE_INV} guiconfig

defconfig: .prereq_done
	@${GMAKE_INV} defconfig

allnoconfig: .prereq_done
	@${GMAKE_INV} _config W=-n

allconfig: .prereq_done
	@${GMAKE_INV} _mconfig W=-y RCONFIG=Config.in

allmodconfig: .prereq_done
	@${GMAKE_INV} _mconfig W=-o RCONFIG=Config.in

package_index: .prereq_done
	@${GMAKE_INV} package_index

bulk: .prereq_done
	@${GMAKE_INV} bulk

bulktoolchain: .prereq_done
	@${GMAKE_INV} bulktoolchain

bulkall: .prereq_done
	@${GMAKE_INV} bulkall

bulkallmod: .prereq_done
	@${GMAKE_INV} bulkallmod

check: .prereq_done
	@${GMAKE_INV} check

menu: .prereq_done
	@${GMAKE_INV} menu

dep: .prereq_done
	@${GMAKE_INV} dep

world: .prereq_done
	@${GMAKE_INV} world

prereq:
	@rm -f .prereq_done
	@${GMAKE} .prereq_done

prereq-noerror:
	@rm -f .prereq_done
	@${GMAKE} .prereq_done NO_ERROR=1

NO_ERROR=0
.prereq_done:
	@-rm -rf .prereq_done
	@if ! bash --version 2>&1 | grep -F 'GNU bash' >/dev/null 2>&1; then \
		echo "GNU bash needs to be installed."; \
		exit 1; \
	fi
	@if test x"$$(umask 2>/dev/null | sed 's/00*22/OK/')" != x"OK"; then \
		echo >&2 Error: you must build with umask 022, sorry.; \
		exit 1; \
	fi
	@echo "TOPDIR:=$$(readlink -nf . 2>/dev/null || pwd -P)" >prereq.mk
	@echo "BASH:=$$(which bash)" >>prereq.mk
	@if [ -z "$$(which gmake 2>/dev/null )" ]; then \
		echo "GMAKE:=$$(which make)" >>prereq.mk ;\
	else \
		echo "GMAKE:=$$(which gmake)" >>prereq.mk ;\
	fi
	@echo "GNU_HOST_NAME:=$$(${CC} -dumpmachine)" >>prereq.mk
	@echo "HOSTARCH:=$$(${CC} -dumpmachine | sed -e s'/-.*//' \
	    -e 's/sparc.*/sparc/' \
	    -e 's/armeb.*/armeb/g' \
	    -e 's/arm.*/arm/g' \
	    -e 's/m68k.*/m68k/' \
	    -e 's/v850.*/v850/g' \
	    -e 's/sh[234]/sh/' \
	    -e 's/mips-.*/mips/' \
	    -e 's/mipsel-.*/mipsel/' \
	    -e 's/cris.*/cris/' \
	    -e 's/i[3-9]86/x86/' \
	    )" >>prereq.mk
	@echo 'CC_FOR_BUILD:=${CC}' >>prereq.mk
	@echo 'CXX_FOR_BUILD:=${CXX}' >>prereq.mk
	@echo 'HOSTCC:=${CC}' >>prereq.mk
	@echo 'HOSTCXX:=${CXX}' >>prereq.mk
	@echo 'LANGUAGE:=C' >>prereq.mk
	@echo 'LC_ALL:=C' >>prereq.mk
	@echo 'MAKE:=$${GMAKE}' >>prereq.mk
	@echo "OStype:=$$(env uname)" >>prereq.mk
	@echo "ADKtype:=$$(cat /etc/adktarget 2>/dev/null)" >>prereq.mk
	@echo "_PATH:=$$PATH" >>prereq.mk
	@echo "PATH:=\$${TOPDIR}/scripts:/usr/sbin:$$PATH" >>prereq.mk
	@echo "SHELL:=$$(which bash)" >>prereq.mk
	@echo "HOST_LIBIDL_CONFIG:=$$(which libIDL-config-2 2>/dev/null)" >>prereq.mk
	@echo "PKG_HOSTLIB_DIR=$$(eval pkg-config --variable pc_path pkg-config 2>/dev/null)" >/dev/null
	@echo "PKG_HOSTLIB_DIR:=$${PKG_HOSTLIB_DIR:-/usr/lib/pkgconfig}" >>prereq.mk
	@env NO_ERROR=${NO_ERROR} BASH="$$(which bash)" \
		CC='${CC}' CPPFLAGS='${CPPFLAGS}' \
	    	bash scripts/scan-tools.sh
	@echo '===> Prerequisites checked successfully.'
	@bash scripts/create-sys
	@bash scripts/create-pkg
	@touch .adkinit
	@touch $@

checkreloc:
	@bash scripts/reloc.sh

.PHONY: prereq prereq-noerror checkreloc

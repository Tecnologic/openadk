# This file is part of the OpenADK project. OpenADK is copyrighted
# material, please see the LICENCE file in the top-level directory.

TOPDIR:=	$(shell pwd)
PWD:=		${TOPDIR}

include Makefile.inc

ADKVERSION=	0.1.0
export ADKVERSION

ifneq (${package},)
subdir:=	package/${package}
_subdir_dep:=	${TOPDIR}/.config
endif

ifneq (${subdir},)
${MAKECMDGOALS}: _subdir

_subdir: ${_subdir_dep}
	@if test x"$$(umask 2>/dev/null | sed 's/00*22/OK/')" != x"OK"; then \
		echo >&2 Error: you must build with “umask 022”, sorry.; \
		exit 1; \
	fi
	cd ${subdir} && TOPDIR=${TOPDIR} \
	    make VERBOSE=1 ${MAKEFLAGS} ${MAKECMDGOALS}

include prereq.mk
else
include Makefile
endif

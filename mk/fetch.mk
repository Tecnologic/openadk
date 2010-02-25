# This file is part of the OpenADK project. OpenADK is copyrighted
# material, please see the LICENCE file in the top-level directory.

ifneq ($(strip ${DIST_SUBDIR}),)
FULLDISTDIR?=		${DISTDIR}/${DIST_SUBDIR}
else
FULLDISTDIR?=		${DISTDIR}
endif

FULLDISTFILES=		$(patsubst %,${FULLDISTDIR}/%,${DISTFILES})

FETCH_STYLE?=		auto
#pre-fetch:
do-fetch:
#post-fetch:
fetch:
#	@${MAKE} pre-fetch
ifneq ($(filter auto,${FETCH_STYLE}),)
	${MAKE} ${FULLDISTFILES}
else
	${MAKE} do-fetch
endif
#	@${MAKE} post-fetch

refetch:
	-rm -f ${FULLDISTFILES}
	${MAKE} fetch

# XXX for now
_CHECKSUM_COOKIE?=	${WRKDIR}/.checksum_done
checksum: ${_CHECKSUM_COOKIE}
ifeq ($(strip ${NO_CHECKSUM}),)
${_CHECKSUM_COOKIE}: ${FULLDISTFILES}
	-rm -rf ${WRKDIR}
	@OK=n; \
	(md5sum ${FULLDISTFILES}; echo exit) | while read sum name; do \
		if [[ $$sum = exit ]]; then \
			[[ $$OK = n ]] && echo >&2 "==> No distfile found!" || :; \
			[[ $$OK = 1 ]] || exit 1; \
			break; \
		fi; \
		if [[ $$sum = "$(strip ${PKG_MD5SUM})" ]]; then \
			[[ $$OK = 0 ]] || OK=1; \
			continue; \
		fi; \
		echo >&2 "==> Checksum mismatch for $${name##*/} (MD5)"; \
		echo >&2 ":---> should be '$(strip ${PKG_MD5SUM})'"; \
		echo >&2 ":---> really is '$$sum'"; \
		OK=0; \
	done
	mkdir -p ${WRKDIR}
	touch ${_CHECKSUM_COOKIE}
endif

# GNU make's poor excuse for loops
define FETCH_template
$(1):
	@fullname='$(1)'; \
	subname=$$$${fullname##$${DISTDIR}/}; \
	filename=$$$${fullname##*/}; \
	i='$${LOCAL_DISTDIR}'; \
	if [[ -n $$$$i && -e $$$$i/$$$$subname ]]; then \
		cd "$$$$i"; \
		echo pax -rw "$$$$subname" '$${DISTDIR}/'; \
		exec pax -rw "$$$$subname" '$${DISTDIR}/'; \
	fi; \
	mkdir -p "$$$${fullname%%/$$$$filename}"; \
	cd "$$$${fullname%%/$$$$filename}"; \
	for site in $${PKG_SITES} $${MASTER_SITE_BACKUP}; do \
		: echo "$${FETCH_CMD} $$$$site$$$$filename"; \
		rm -f "$$$$filename"; \
		if $${FETCH_CMD} $$$$site$$$$filename; then \
			: check the size here; \
			[[ ! -e $$$$filename ]] || exit 0; \
		fi; \
	done; \
	exit 1
endef

$(foreach distfile,${FULLDISTFILES},$(eval $(call FETCH_template,$(distfile))))

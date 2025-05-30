SNAPSHOT ?= $(shell date +%Y%m%d)
SNAPSHOT_FILE=snapshots/gentoo-$(SNAPSHOT).tar.bz2

CHOST ?= $(shell gcc -dumpmachine)
ARCH ?= $(shell sh scripts/getarch.sh $(CHOST))

SEED_FILE ?= $(shell sh scripts/getseedfile.sh $(REL_TYPE) $(ARCH) $(ABI) )
SEED ?= $(shell	sh scripts/getseed.sh $(SEED_FILE))

BUILD_STAMP=$(SUBARCH)$(ABI)-$(SNAPSHOT)

all: builds/$(REL_TYPE)/stage3-$(BUILD_STAMP).tar.bz2

specs/$(REL_TYPE)/stage1-$(BUILD_STAMP).spec: scripts/mkspec.sh
	[ -d $(@D) ] || mkdir $(@D)
	sh -ex scripts/mkspec.sh \
			--target stage1	\
			--abi "$(ABI)" \
			--arch "$(ARCH)" \
			--subarch "$(SUBARCH)" \
			--snapshot "$(SNAPSHOT)" \
			--version "$(VERSION)" \
			--rel-type "$(REL_TYPE)" \
			--profile "$(PROFILE)" \
			--source "$(SEED)" \
			--overlay "$(OVERLAY)" \
			--confdir "$(CONFDIR)" \
			--chost "$(CHOST)" \
			--cflags "$(CFLAGS)" > $@

specs/$(REL_TYPE)/stage2-$(BUILD_STAMP).spec: scripts/mkspec.sh
	[ -d $(@D) ] || mkdir $(@D)
	sh -ex scripts/mkspec.sh \
			--target stage2	\
			--abi "$(ABI)" \
			--arch "$(ARCH)" \
			--subarch "$(SUBARCH)" \
			--snapshot "$(SNAPSHOT)" \
			--version "$(VERSION)" \
			--rel-type "$(REL_TYPE)" \
			--profile "$(PROFILE)" \
			--source "$(REL_TYPE)/stage1-$(BUILD_STAMP)" \
			--overlay "$(OVERLAY)" \
			--confdir "$(CONFDIR)" \
			--chost "$(CHOST)" \
			--cflags "$(CFLAGS)" > $@

specs/$(REL_TYPE)/stage3-$(BUILD_STAMP).spec: scripts/mkspec.sh
	[ -d $(@D) ] || mkdir $(@D)
	sh -ex scripts/mkspec.sh \
			--target stage3	\
			--abi "$(ABI)" \
			--arch "$(ARCH)" \
			--subarch "$(SUBARCH)" \
			--snapshot "$(SNAPSHOT)" \
			--version "$(VERSION)" \
			--rel-type "$(REL_TYPE)" \
			--profile "$(PROFILE)" \
			--source "$(REL_TYPE)/stage2-$(BUILD_STAMP)" \
			--overlay "$(OVERLAY)" \
			--confdir "$(CONFDIR)" \
			--cflags "$(CFLAGS)" > $@

builds/$(REL_TYPE)/stage1-$(BUILD_STAMP).tar.bz2: \
		specs/$(REL_TYPE)/stage1-$(BUILD_STAMP).spec \
		$(SEED_FILE) $(SNAPSHOT_FILE)
	catalyst -f $<
ifeq ($(BUILD_LATEST),y)
	rm -f builds/$(REL_TYPE)/stage1-$(SUBARCH)$(ABI)-latest.tar.bz2
	ln -s $(@F) builds/$(REL_TYPE)/stage1-$(SUBARCH)$(ABI)-latest.tar.bz2
endif

builds/$(REL_TYPE)/stage2-$(BUILD_STAMP).tar.bz2: \
		specs/$(REL_TYPE)/stage2-$(BUILD_STAMP).spec \
		builds/$(REL_TYPE)/stage1-$(BUILD_STAMP).tar.bz2 \
		$(SNAPSHOT_FILE)
	catalyst -f $<
ifeq ($(BUILD_LATEST),y)
	rm -f builds/$(REL_TYPE)/stage2-$(SUBARCH)$(ABI)-latest.tar.bz2
	ln -s $(@F) builds/$(REL_TYPE)/stage2-$(SUBARCH)$(ABI)-latest.tar.bz2
endif

builds/$(REL_TYPE)/stage3-$(BUILD_STAMP).tar.bz2: \
		specs/$(REL_TYPE)/stage3-$(BUILD_STAMP).spec \
		builds/$(REL_TYPE)/stage2-$(BUILD_STAMP).tar.bz2 \
		$(SNAPSHOT_FILE)
	catalyst -f $<
ifeq ($(BUILD_LATEST),y)
	rm -f builds/$(REL_TYPE)/stage3-$(SUBARCH)$(ABI)-latest.tar.bz2
	ln -s $(@F) builds/$(REL_TYPE)/stage3-$(SUBARCH)$(ABI)-latest.tar.bz2
endif

$(SNAPSHOT_FILE):
	catalyst -s $(SNAPSHOT)

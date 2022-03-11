# Gentoo Catalyst build wrapper

Gentoo Catalyst is the release engineering tool used by Gentoo developers to
build installation media for Gentoo Linux.

This is a wrapper around this tool to make generation of stages simpler.  It is
a derivative of an earlier script of mine that was used for many years to
produce Gentoo's official MIPS builds.

## Typical usage

Normally these scripts live in `/var/tmp/catalyst` along side
Catalyst-generated files.

### Compiling from a rough "seed" stage

To generate such a seed file; do `env ROOT=/tmp/somewhere emerge -e @system`;
then tar up the contents of `/tmp/somewhere` and place it in
`/var/tmp/catalyst/builds`.

```
# make SEED_FILE=builds/initseed-glibc-amd64-20220310.tar.bz2 \
       REL_TYPE=hardenedseed PROFILE=default/linux/amd64/17.1/hardened \
       ARCH=amd64 SUBARCH=amd64 
```

Then to produce your actual release:

```
# make SEED_FILE=builds/hardenedseed/stage3-amd64-20220310.tar.bz2 \
       REL_TYPE=hardened PROFILE=default/linux/amd64/17.1/hardened \
       ARCH=amd64 SUBARCH=amd64 
```

### Other build types

Read the code… I wrote this many moons ago, and last looked at it back in
2019.  It's been a long few years so I don't recall all of the options right
now.


## Gotchas

### `libcap` and `pam` circular dependencies

At stage 3, you might encounter this error:
```
 * Error: circular dependencies:

(sys-libs/libcap-2.63:0/0::gentoo, ebuild scheduled for merge) depends on
 (sys-libs/pam-1.5.1_p20210622-r1:0/0::gentoo, ebuild scheduled for merge) (buildtime)
  (sys-libs/libcap-2.63:0/0::gentoo, ebuild scheduled for merge) (buildtime)

It might be possible to break this cycle
by applying any of the following changes:
- sys-libs/pam-1.5.1_p20210622-r1 (Change USE: -filecaps)
- sys-libs/libcap-2.63 (Change USE: -pam)
```

The issue is documented in [bug 663440](https://bugs.gentoo.org/663440).  There
are two ways of getting around this:

#### Method 1: manually `chroot` and temporarily install `libcap` without `pam`

```
# for d in dev proc sys run ; do \
    mount -o bind /$d …/catalyst/tmp/hardened/stage3-amd64-20220311; \
  done
# mount -o bind …/catalyst/snapshots/20220311 \
        …/catalyst/tmp/hardened/stage3-amd64-20220311/var/db/repos/gentoo
# chroot …/catalyst/tmp/hardened/stage3-amd64-20220311
(chroot) # env USE=-pam emerge -1v libcap
(chroot) # exit
# for d in var/lib/repos/gentoo dev proc sys run; do \
    umount $d; \
  done
```

… then re-run your `make`.

#### Method 2: use a portage configuration directory

This is actually what Gentoo do upstream these days.

```
# git clone https://anongit.gentoo.org/git/proj/releng.git
# rm specs/hardened/stage3-amd64-20220311.spec
# make SEED_FILE=builds/hardenedseed/stage3-amd64-20220310.tar.bz2 \
       REL_TYPE=hardened PROFILE=default/linux/amd64/17.1/hardened \
       ARCH=amd64 SUBARCH=amd64 SNAPSHOT=20220311 \
       CONFDIR=…/releng/releases/portage/stages
```

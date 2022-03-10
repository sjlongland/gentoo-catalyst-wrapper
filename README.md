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

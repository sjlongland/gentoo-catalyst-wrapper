#!/bin/sh
seed=$1
if [ -L "${seed}" ]; then
	seed="$( dirname "${seed}" )/$( readlink "${seed}" )"
fi
seed="${seed%%.tar.bz2}"
seed="${seed##builds/}"
echo "${seed}"

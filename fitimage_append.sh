#!/bin/bash
set -x

REL=..

echo $*
rm -rf ramdisk.cpio ramdisk

ORIG_FIT=$REL/$1
shift
ITS_FILE=$REL/$1
shift

APPEND_LIST=()

while [ "$1" != "" ]
do
  if [ "${1:0:1}" == "+" ]
  then
	  APPEND_LIST+=(${1:1})
  fi

  shift
done

dumpimage -T flat_dt -p 0 -o Image           $ORIG_FIT
dumpimage -T flat_dt -p 1 -o xen.dtb         $ORIG_FIT
dumpimage -T flat_dt -p 2 -o bl31.bin        $ORIG_FIT
dumpimage -T flat_dt -p 3 -o xen             $ORIG_FIT
dumpimage -T flat_dt -p 4 -o xenpolicy       $ORIG_FIT
dumpimage -T flat_dt -p 5 -o ramdisk.cpio.gz $ORIG_FIT

gzip -d ramdisk.cpio.gz
mkdir -p ramdisk

(cd ramdisk/ && cpio -idm -F ../ramdisk.cpio)

for item in ${APPEND_LIST[@]}
do
	src=$(echo $item | sed 's/^\(.*\):.*/\1/')
	dst=$(echo $item | sed 's/^.*:\(.*\)/\1/' | sed 's/^\/*//')

	if [ ${dst: -1} == "/" ]
	then
		mkdir -p ramdisk/${dst}
	else
		mkdir -p ramdisk/$(dirname ${dst})
	fi

	cp $REL/$src ramdisk/$dst
done

(cd ramdisk/ && find . | cpio -H newc -o -R root:root | gzip > ../uInitramfs)

cp $ITS_FILE .
mkimage -f $(basename $ITS_FILE) fitImage

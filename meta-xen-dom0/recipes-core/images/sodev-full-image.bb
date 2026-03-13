SUMMARY = "Full SoDeV disk image assembled without moulin/rouge"
DESCRIPTION = "Creates the GPT disk image with a boot partition and a DomD rootfs partition."

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"

inherit image

IMAGE_INSTALL = ""
PACKAGE_INSTALL = ""
IMAGE_FEATURES = ""
IMAGE_LINGUAS = ""

IMAGE_FSTYPES = "wic"
WKS_FILE = "sodev-full-image.wks.in"
WKS_FILE_DEPENDS = "e2fsprogs-native dosfstools-native mtools-native gptfdisk-native"
WICVARS:append = " SODEV_FULL_DOMD_ROOTFS"

SODEV_FULL_DOM0_FITIMAGE = "${TOPDIR}/tmp/deploy/images/generic-armv8-xt/fitImage"
SODEV_FULL_DOM0_FLASHBIN = "${TOPDIR}/../build-domd/tmp/deploy/images/${DOMD_MACHINE}/flash.bin"
SODEV_FULL_DOMD_ROOTFS = "${TOPDIR}/../build-domd/tmp/deploy/images/${DOMD_MACHINE}/core-image-weston-${DOMD_MACHINE}.rootfs.ext4"

IMAGE_BOOT_FILES = " \
    ${SODEV_FULL_DOM0_FITIMAGE};fitImage \
    ${SODEV_FULL_DOM0_FLASHBIN};flash.bin \
    ${SODEV_FULL_DOM0_FITIMAGE};boot/fitImage \
"

do_image_wic[depends] += "core-image-thin-initramfs:do_image_complete"
do_image_wic[prefuncs] += "sodev_full_check_inputs"
do_populate_lic_deploy[noexec] = "1"

sodev_full_check_inputs() {
    [ -e "${SODEV_FULL_DOM0_FITIMAGE}" ] || bbfatal "Missing fitImage file: ${SODEV_FULL_DOM0_FITIMAGE}"
    [ -e "${SODEV_FULL_DOM0_FLASHBIN}" ] || bbfatal "Missing flash.bin file: ${SODEV_FULL_DOM0_FLASHBIN}"
    [ -e "${SODEV_FULL_DOMD_ROOTFS}" ] || bbfatal "Missing DomD rootfs ext4 file: ${SODEV_FULL_DOMD_ROOTFS}"
}

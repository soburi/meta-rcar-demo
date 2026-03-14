SUMMARY = "Full Xen disk image assembled without moulin/rouge"
DESCRIPTION = "Creates the GPT disk image with a boot partition and a DomD rootfs partition."

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"

inherit image

IMAGE_INSTALL = ""
PACKAGE_INSTALL = ""
IMAGE_FEATURES = ""
IMAGE_LINGUAS = ""

IMAGE_FSTYPES = "wic"
WKS_FILE = "xen-full-image.wks.in"
WKS_FILE_DEPENDS = "e2fsprogs-native dosfstools-native mtools-native gptfdisk-native"
WICVARS:append = " XEN_FULL_DOMD_ROOTFS"

XEN_FULL_DOM0_FITIMAGE = "${TOPDIR}/tmp-dom0/deploy/images/${MACHINE}/fitImage"
XEN_FULL_DOM0_FLASHBIN = "${TOPDIR}/tmp-domd/deploy/images/${MACHINE}/ipl-burning/flash.bin"
XEN_FULL_DOMD_ROOTFS = "${TOPDIR}/tmp-domd/deploy/images/${MACHINE}/core-image-weston-${MACHINE}.rootfs.ext4"

IMAGE_BOOT_FILES = " \
    ${XEN_FULL_DOM0_FITIMAGE};fitImage \
    ${XEN_FULL_DOM0_FLASHBIN};flash.bin \
    ${XEN_FULL_DOM0_FITIMAGE};boot/fitImage \
"

do_image_wic[depends] += "fitimage:do_deploy"
do_image_wic[mcdepends] += " \
    mc:dom0:domd:ipl-burning:do_deploy \
    mc:dom0:domd:core-image-weston:do_image_complete \
"
do_image_wic[prefuncs] += "xen_full_resolve_domd_rootfs xen_full_check_inputs"
do_populate_lic_deploy[noexec] = "1"

xen_full_resolve_domd_rootfs() {
    if [ -e "${XEN_FULL_DOMD_ROOTFS}" ]; then
        return
    fi

    local src_ext4
    local src_pattern="${TOPDIR}/tmp-domd/deploy/images/${MACHINE}/core-image-weston-${MACHINE}.rootfs-"*.ext4

    src_ext4=$(ls -1t ${src_pattern} 2>/dev/null | head -n1 || true)
    if [ -z "${src_ext4}" ]; then
        bbfatal "Missing DomD rootfs ext4 source file. Looked for ${src_pattern}"
    fi

    ln -sf "$(basename "${src_ext4}")" "${XEN_FULL_DOMD_ROOTFS}"
}

xen_full_check_inputs() {
    [ -e "${XEN_FULL_DOM0_FITIMAGE}" ] || bbfatal "Missing fitImage file: ${XEN_FULL_DOM0_FITIMAGE}"
    [ -e "${XEN_FULL_DOM0_FLASHBIN}" ] || bbfatal "Missing flash.bin file: ${XEN_FULL_DOM0_FLASHBIN}"
    [ -e "${XEN_FULL_DOMD_ROOTFS}" ] || bbfatal "Missing DomD rootfs ext4 file: ${XEN_FULL_DOMD_ROOTFS}"
}

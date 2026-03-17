SUMMARY = "Full SoDeV disk image assembled without moulin/rouge"
DESCRIPTION = "Creates a GPT disk image aligned with moulin full.img semantics."

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
WICVARS:append = " SODEV_FULL_DOMD_ROOTFS SODEV_FULL_FREE_SPACE SODEV_FULL_OPTIONAL_PARTS"

SODEV_FULL_DOM0_FITIMAGE = "${TOPDIR}/tmp-dom0/deploy/images/${MACHINE}/fitImage"
SODEV_FULL_DOM0_FLASHBIN = "${TOPDIR}/tmp-domd/deploy/images/${DOMD_MACHINE}/ipl-burning/flash.bin"
SODEV_FULL_DOMD_ROOTFS = "${TOPDIR}/tmp-domd/deploy/images/${DOMD_MACHINE}/core-image-weston-${DOMD_MACHINE}.rootfs.ext4"
SODEV_FULL_DOMU_ROOTFS ?= ""
SODEV_FULL_DOMU_AGL_IVI_ROOTFS ?= ""
SODEV_FULL_DOMU_AGL_IC_ROOTFS ?= ""
SODEV_FULL_ANDROID_IMAGE ?= ""
SODEV_FULL_FREE_SPACE = "16367K"
SODEV_FULL_OPTIONAL_PARTS = ""
DOMD_MCDEP_PREFIX = "mc:dom0:domd"

IMAGE_BOOT_FILES = " \
    ${SODEV_FULL_DOM0_FITIMAGE};fitImage \
    ${SODEV_FULL_DOM0_FLASHBIN};flash.bin \
    ${SODEV_FULL_DOM0_FITIMAGE};boot/fitImage \
"

do_image_wic[depends] += "core-image-thin-initramfs:do_image_complete"
do_image_wic[mcdepends] += " \
    ${DOMD_MCDEP_PREFIX}:ipl-burning:do_deploy \
    ${DOMD_MCDEP_PREFIX}:core-image-weston:do_image_complete \
"
do_image_wic[prefuncs] += "sodev_full_resolve_domd_rootfs sodev_full_check_inputs"
do_populate_lic_deploy[noexec] = "1"

do_prepare_domd_disk_inputs[mcdepends] += " \
    ${DOMD_MCDEP_PREFIX}:ipl-burning:do_deploy \
    ${DOMD_MCDEP_PREFIX}:core-image-weston:do_image_complete \
"

python __anonymous() {
    parts = []

    for varname, mountpoint, part_name in (
        ("SODEV_FULL_DOMU_ROOTFS", "/domu-rootfs", "domu-rootfs"),
        ("SODEV_FULL_DOMU_AGL_IVI_ROOTFS", "/domu-agl-ivi-rootfs", "domu-agl-ivi-rootfs"),
        ("SODEV_FULL_DOMU_AGL_IC_ROOTFS", "/domu-agl-ic-rootfs", "domu-agl-ic-rootfs"),
    ):
        image_path = d.getVar(varname) or ""
        if image_path:
            parts.append(
                "part %s --source rawcopy --sourceparams=\"file=%s\" "
                "--ondisk mmcblk0 --align 1024 --part-name %s "
                "--part-type 0FC63DAF-8483-4772-8E79-3D69D8477DE4" %
                (mountpoint, image_path, part_name)
            )

    android_image = d.getVar("SODEV_FULL_ANDROID_IMAGE") or ""
    if android_image:
        parts.append(
            "part /android --source rawcopy --sourceparams=\"file=%s\" "
            "--ondisk mmcblk0 --align 1024 --part-name android "
            "--part-type A326898F-C893-4A64-9990-6F6B7BFDEF18" %
            android_image
        )

    d.setVar("SODEV_FULL_OPTIONAL_PARTS", "\n".join(parts))
}

do_prepare_domd_disk_inputs() {
    :
}
addtask do_prepare_domd_disk_inputs before do_image_wic after do_rootfs

sodev_full_resolve_domd_rootfs() {
    if [ -e "${SODEV_FULL_DOMD_ROOTFS}" ]; then
        return
    fi

    local src_ext4
    local src_pattern="${TOPDIR}/tmp-domd/deploy/images/${DOMD_MACHINE}/core-image-weston-${DOMD_MACHINE}.rootfs-"*.ext4

    src_ext4=$(ls -1t ${src_pattern} 2>/dev/null | head -n1 || true)
    if [ -z "${src_ext4}" ]; then
        bbfatal "Missing DomD rootfs ext4 source file. Looked for ${src_pattern}"
    fi

    ln -sf "$(basename "${src_ext4}")" "${SODEV_FULL_DOMD_ROOTFS}"
}

sodev_full_check_inputs() {
    [ -e "${SODEV_FULL_DOM0_FITIMAGE}" ] || bbfatal "Missing fitImage file: ${SODEV_FULL_DOM0_FITIMAGE}"
    [ -e "${SODEV_FULL_DOM0_FLASHBIN}" ] || bbfatal "Missing flash.bin file: ${SODEV_FULL_DOM0_FLASHBIN}"
    [ -e "${SODEV_FULL_DOMD_ROOTFS}" ] || bbfatal "Missing DomD rootfs ext4 file: ${SODEV_FULL_DOMD_ROOTFS}"
    if [ -n "${SODEV_FULL_DOMU_ROOTFS}" ]; then
        [ -e "${SODEV_FULL_DOMU_ROOTFS}" ] || bbfatal "Missing DomU rootfs ext4 file: ${SODEV_FULL_DOMU_ROOTFS}"
    fi
    if [ -n "${SODEV_FULL_DOMU_AGL_IVI_ROOTFS}" ]; then
        [ -e "${SODEV_FULL_DOMU_AGL_IVI_ROOTFS}" ] || bbfatal "Missing DomU AGL IVI rootfs ext4 file: ${SODEV_FULL_DOMU_AGL_IVI_ROOTFS}"
    fi
    if [ -n "${SODEV_FULL_DOMU_AGL_IC_ROOTFS}" ]; then
        [ -e "${SODEV_FULL_DOMU_AGL_IC_ROOTFS}" ] || bbfatal "Missing DomU AGL IC rootfs ext4 file: ${SODEV_FULL_DOMU_AGL_IC_ROOTFS}"
    fi
    if [ -n "${SODEV_FULL_ANDROID_IMAGE}" ]; then
        [ -e "${SODEV_FULL_ANDROID_IMAGE}" ] || bbfatal "Missing Android sub-image file: ${SODEV_FULL_ANDROID_IMAGE}"
    fi
}

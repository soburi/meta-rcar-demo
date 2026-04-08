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
WKS_FILE = "sodev-integrated-image.wks.in"
WKS_FILE_DEPENDS = "e2fsprogs-native dosfstools-native mtools-native gptfdisk-native"
WICVARS:append = " SODEV_IMAGE_DOMD_IMAGE SODEV_IMAGE_FREE_SPACE SODEV_IMAGE_PARTS"

SODEV_IMAGE_DOM0_DEPLOY_DIR = "${TOPDIR}/tmp/deploy/images/${MACHINE}"
SODEV_IMAGE_DOM0_FITIMAGE = "${SODEV_IMAGE_DOM0_DEPLOY_DIR}/fitImage"
SODEV_IMAGE_DOM0_FLASHBIN = "${SODEV_IMAGE_DOM0_DEPLOY_DIR}/ipl-burning/flash.bin"
SODEV_IMAGE_DOMD ?= ""
SODEV_IMAGE_DOMU ?= ""
SODEV_IMAGE_DOMU_AGL_IVI ?= ""
SODEV_IMAGE_DOMU_AGL_IC ?= ""
SODEV_IMAGE_ANDROID ?= ""
SODEV_IMAGE_FREE_SPACE = "16367K"

def sodev_image_parts(d):
    import os

    specs = [
        {
            "var": "SODEV_IMAGE_DOMD",
            "partition": "domd-rootfs",
            "gpt_type": "B921B045-1DF0-41C3-AF44-4C6F280D3FAE"
        },
        {
            "var": "SODEV_IMAGE_DOMU",
            "partition": "domu-rootfs",
            "gpt_type": "0FC63DAF-8483-4772-8E79-3D69D8477DE4"
        },
        {
            "var": "SODEV_IMAGE_ANDROID",
            "partition": "android",
            "gpt_type": "A326898F-C893-4A64-9990-6F6B7BFDEF18"
        },
        {
            "var": "SODEV_IMAGE_DOMU_AGL_IVI",
            "partition": "domu-agl-ivi-rootfs",
            "gpt_type": "0FC63DAF-8483-4772-8E79-3D69D8477DE4"
        },
        {
            "var": "SODEV_IMAGE_DOMU_AGL_IC",
            "partition": "domu-agl-ic-rootfs",
            "gpt_type": "0FC63DAF-8483-4772-8E79-3D69D8477DE4"
        },
    ]
    parts = []

    for spec in specs:
        image_path = d.getVar(spec["var"]) or ""
        if not image_path:
            continue

        if not os.path.exists(image_path):
            continue

        parts.append(
            'part %s --source rawcopy --sourceparams="file=%s" '
            '--ondisk mmcblk0 --align 1024 --part-name %s '
            '--part-type %s' % ('/' + spec["partition"], image_path, spec["partition"], spec["gpt_type"])
        )

    return "\n".join(parts)

SODEV_IMAGE_PARTS = "${@sodev_image_parts(d)}"

IMAGE_BOOT_FILES = " \
    ${SODEV_IMAGE_DOM0_FITIMAGE};fitImage \
    ${SODEV_IMAGE_DOM0_FLASHBIN};flash.bin \
    ${SODEV_IMAGE_DOM0_FITIMAGE};boot/fitImage \
"

do_image_wic[depends] += " \
    core-image-thin-initramfs:do_image_complete \
    linux-fitimage:do_compile \
    sparrow-hawk-xen-dtb:do_deploy \
    xen:do_deploy \
    xen-tools:do_deploy \
    ipl-burning:do_deploy \
"

do_populate_lic_deploy[noexec] = "1"

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
WICVARS:append = " SODEV_FULL_DOMD_IMAGE SODEV_FULL_FREE_SPACE SODEV_FULL_OPTIONAL_PARTS"

SODEV_FULL_DOM0_DEPLOY_DIR = "${TOPDIR}/tmp/deploy/images/${MACHINE}"
SODEV_FULL_DOM0_FITIMAGE = "${SODEV_FULL_DOM0_DEPLOY_DIR}/fitImage"
SODEV_FULL_DOM0_FLASHBIN = "${SODEV_FULL_DOM0_DEPLOY_DIR}/ipl-burning/flash.bin"
SODEV_FULL_DOMD_IMAGE ?= ""
SODEV_FULL_DOMU_IMAGE ?= ""
SODEV_FULL_DOMU_AGL_IVI_IMAGE ?= ""
SODEV_FULL_DOMU_AGL_IC_IMAGE ?= ""
SODEV_FULL_ANDROID_IMAGE ?= ""
SODEV_FULL_FREE_SPACE = "16367K"

def sodev_full_optional_parts(d):
    import os

    specs = [
        {
            "var": "SODEV_FULL_DOMD_IMAGE",
            "partition": "domd-rootfs",
            "gpt_type": "B921B045-1DF0-41C3-AF44-4C6F280D3FAE"
        },
        {
            "var": "SODEV_FULL_DOMU_IMAGE",
            "partition": "domu-rootfs",
            "gpt_type": "0FC63DAF-8483-4772-8E79-3D69D8477DE4"
        },
        {
            "var": "SODEV_FULL_ANDROID_IMAGE",
            "partition": "android",
            "gpt_type": "A326898F-C893-4A64-9990-6F6B7BFDEF18"
        },
        {
            "var": "SODEV_FULL_DOMU_AGL_IVI_IMAGE",
            "partition": "domu-agl-ivi-rootfs",
            "gpt_type": "0FC63DAF-8483-4772-8E79-3D69D8477DE4"
        },
        {
            "var": "SODEV_FULL_DOMU_AGL_IC_IMAGE",
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

SODEV_FULL_OPTIONAL_PARTS = "${@sodev_full_optional_parts(d)}"

IMAGE_BOOT_FILES = " \
    ${SODEV_FULL_DOM0_FITIMAGE};fitImage \
    ${SODEV_FULL_DOM0_FLASHBIN};flash.bin \
    ${SODEV_FULL_DOM0_FITIMAGE};boot/fitImage \
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

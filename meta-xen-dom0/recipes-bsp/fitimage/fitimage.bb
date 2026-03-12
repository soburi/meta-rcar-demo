SUMMARY = "Generate Dom0 fitImage"
DESCRIPTION = "Assemble the Dom0 fitImage from Dom0 initramfs and DomD stable deploy artifacts."

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"

inherit deploy nopackages

DEPENDS += "u-boot-mkimage-native dtc-native"

FILESEXTRAPATHS:prepend := "${THISDIR}/../../recipes-core/core-image-thin-initramfs/files:"
SRC_URI += " file://fit-image.its"

DOM0_DEPLOY_DIR = "${TOPDIR}/tmp/deploy/images/generic-armv8-xt"
DOMD_DEPLOY_DIR = "${TOPDIR}/../build-domd/tmp/deploy/images/${MACHINE}"
FITIMAGE_OUTPUT = "${WORKDIR}/fitImage"

do_deploy[depends] += " \
    core-image-thin-initramfs:do_deploy \
    virtual/kernel:do_deploy \
"

do_deploy() {
    cd ${WORKDIR}
    cp -f ${DOM0_DEPLOY_DIR}/Image ./Image
    cp -f ${DOM0_DEPLOY_DIR}/uInitramfs ./uInitramfs
    cp -Lf ${DOMD_DEPLOY_DIR}/xen-${MACHINE} ./xen
    cp -Lf ${DOMD_DEPLOY_DIR}/xenpolicy-${MACHINE} ./xenpolicy
    cp -Lf ${DOMD_DEPLOY_DIR}/${XT_XEN_DTB_NAME} ./xen.dtb
    cp -Lf ${DOMD_DEPLOY_DIR}/bl31-${MACHINE}.bin ./bl31.bin
    rm -f ${FITIMAGE_OUTPUT}
    mkimage -f ./fit-image.its ${FITIMAGE_OUTPUT}

    install -d ${DEPLOYDIR}
    install -m 0644 ${FITIMAGE_OUTPUT} ${DEPLOYDIR}/fitImage
}

addtask do_deploy after do_prepare_recipe_sysroot before do_build

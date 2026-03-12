DEPENDS += "u-boot-mkimage-native dtc-native"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
inherit deploy
inherit externalsrc
EXTERNALSRC_SYMLINKS = ""
DOMD_DEPLOY_DIR = "${TOPDIR}/tmp-domd/deploy/images/${MACHINE}"

do_image_complete[mcdepends] += " \
    mc:dom0:domd:virtual/kernel:do_deploy \
    mc:dom0:domd:xen:do_deploy \
    mc:dom0:domd:xen-tools:do_deploy \
    mc:dom0:domd:arm-trusted-firmware:do_deploy \
"

generate_uboot_image() {
    uboot-mkimage -A arm64 -O linux -T ramdisk -C gzip -n "uInitramfs" \
        -d ${IMGDEPLOYDIR}/${IMAGE_NAME}.cpio.gz  ${IMGDEPLOYDIR}/${IMAGE_NAME}.cpio.gz.uInitramfs
    ln -sfr  ${IMGDEPLOYDIR}/${IMAGE_NAME}.cpio.gz.uInitramfs ${DEPLOY_DIR_IMAGE}/uInitramfs
}

IMAGE_POSTPROCESS_COMMAND += " generate_uboot_image; "
IMAGE_ROOTFS_SIZE = "65535"
INITRAMFS_MAXSIZE = "262144"

# do_unpack is not supported with inherit core-image.
# Thus, we need to copy file manually.
BBAPPEND_FILE_PATH := "${THISDIR}"
do_copy_files () {
    cp -f ${BBAPPEND_FILE_PATH}/files/fit-image.its -t ${WORKDIR}/
    cp -f ${BBAPPEND_FILE_PATH}/files/fit-image-extra.its -t ${WORKDIR}/
}
addtask do_copy_files before do_image_complete

append_bin_image() {
    local fit_dir="${@d.getVar('EXTERNALSRC') or d.expand('${TOPDIR}/tmp/deploy/images/${DOMD_MACHINE}')}"
    local bin_basename=${1%.bin}

    if [ -n "${fit_dir}" ] && [ -f "${fit_dir}/${bin_basename}.bin" ]; then
        cp -f "${fit_dir}/${bin_basename}.bin" "./${bin_basename}.bin"
        cat >> ./fit-image-extra.its <<EOF
		${bin_basename} {
			description = "${bin_basename} guest";
			data = /incbin/("./${bin_basename}.bin");
			type = "firmware";
			arch = "arm64";
			compression = "none";
			hash-1 {
				algo = "crc32";
			};
		};
EOF
    fi

}

generate_fit_image() {
    cd ${WORKDIR}
    cp -f ${DEPLOY_DIR_IMAGE}/Image ./Image
    cp -f ${IMGDEPLOYDIR}/${IMAGE_NAME}.cpio.gz ./uInitramfs
    cp -f ${DOMD_DEPLOY_DIR}/xen-${MACHINE}.efi ./xen
    cp -f ${DOMD_DEPLOY_DIR}/xenpolicy-${MACHINE} ./xenpolicy
    cp -f ${DOMD_DEPLOY_DIR}/${XT_XEN_DTB_NAME} ./xen.dtb
    cp -f ${DOMD_DEPLOY_DIR}/bl31-${MACHINE}.bin ./bl31.bin

    echo "" > ./fit-image-extra.its

    append_bin_image zephyr_blinky.bin

    mkimage -f ./fit-image.its ${DEPLOY_DIR_IMAGE}/fitImage
}

IMAGE_POSTPROCESS_COMMAND += " generate_fit_image"

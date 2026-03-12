DEPENDS += "u-boot-mkimage-native dtc-native"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
inherit deploy

IMAGE_ROOTFS_SIZE = "65535"
INITRAMFS_MAXSIZE = "262144"
CPIO_INPUT="${WORKDIR}/deploy-${IMAGE_BASENAME}-image-complete/${IMAGE_LINK_NAME}.cpio.gz"

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
    cp -f ${S}/xen-*.efi ./xen
    cp -f ${S}/xenpolicy-4.* ./xenpolicy
    cp -f ${S}/${XT_XEN_DTB_NAME} ./xen.dtb
    cp -f ${S}/bl31-*.bin ./bl31.bin

    echo "" > ./fit-image-extra.its

    append_bin_image zephyr_blinky.bin

    mkimage -f ./fit-image.its ${DEPLOY_DIR_IMAGE}/fitImage
}

addtask do_deploy after do_image_complete before do_build

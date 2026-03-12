DEPENDS += "u-boot-mkimage-native dtc-native"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
inherit deploy

IMAGE_ROOTFS_SIZE = "65535"
INITRAMFS_MAXSIZE = "262144"
CPIO_INPUT="${WORKDIR}/deploy-${IMAGE_BASENAME}-image-complete/${IMAGE_LINK_NAME}.cpio.gz"

do_deploy() {
    [ -e "${CPIO_INPUT}" ] || bbfatal "Could not find initramfs cpio.gz for uInitramfs generation: ${CPIO_INPUT}"

    uboot-mkimage \
        -A arm64 \
        -O linux \
        -T ramdisk \
        -C gzip \
        -n "dom0 initramfs" \
        -d "${CPIO_INPUT}" \
        "${WORKDIR}/uInitramfs"

    install -d ${DEPLOYDIR}
    install -m 0644 ${WORKDIR}/uInitramfs ${DEPLOYDIR}/uInitramfs
}

addtask do_deploy after do_image_complete before do_build

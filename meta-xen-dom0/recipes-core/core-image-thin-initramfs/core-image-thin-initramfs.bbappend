DEPENDS += "u-boot-mkimage-native dtc-native"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
inherit deploy
DOMD_DEPLOY_DIR = "${TOPDIR}/tmp-domd/deploy/images/${DOMD_MACHINE}"
DOMD_INITRAMFS_DEPLOY_NAME = "initramfs-domd.cpio.gz"
DOMD_MCDEP_PREFIX = "mc:dom0:domd"

do_prepare_domd_boot_artifacts[mcdepends] += " \
    ${DOMD_MCDEP_PREFIX}:virtual/kernel:do_deploy \
    ${DOMD_MCDEP_PREFIX}:initramfs-image:do_image_complete \
"
do_prepare_domd_fit_inputs[mcdepends] += " \
    ${DOMD_MCDEP_PREFIX}:virtual/kernel:do_deploy \
    ${DOMD_MCDEP_PREFIX}:xen:do_deploy \
    ${DOMD_MCDEP_PREFIX}:xen-tools:do_deploy \
    ${DOMD_MCDEP_PREFIX}:arm-trusted-firmware:do_deploy \
    ${DOMD_MCDEP_PREFIX}:ipl-burning:do_deploy \
    ${DOMD_MCDEP_PREFIX}:core-image-weston:do_image_complete \
"
do_rootfs[mcdepends] += " \
    ${DOMD_MCDEP_PREFIX}:virtual/kernel:do_deploy \
    ${DOMD_MCDEP_PREFIX}:initramfs-image:do_image_complete \
"
do_image_complete[mcdepends] += " \
    ${DOMD_MCDEP_PREFIX}:virtual/kernel:do_deploy \
    ${DOMD_MCDEP_PREFIX}:xen:do_deploy \
    ${DOMD_MCDEP_PREFIX}:xen-tools:do_deploy \
    ${DOMD_MCDEP_PREFIX}:arm-trusted-firmware:do_deploy \
    ${DOMD_MCDEP_PREFIX}:ipl-burning:do_deploy \
    ${DOMD_MCDEP_PREFIX}:core-image-weston:do_image_complete \
"

generate_uboot_image() {
    uboot-mkimage -A arm64 -O linux -T ramdisk -C gzip -n "uInitramfs" \
        -d ${IMGDEPLOYDIR}/${IMAGE_NAME}.cpio.gz  ${IMGDEPLOYDIR}/${IMAGE_NAME}.cpio.gz.uInitramfs
    ln -sfr  ${IMGDEPLOYDIR}/${IMAGE_NAME}.cpio.gz.uInitramfs ${DEPLOY_DIR_IMAGE}/uInitramfs
}

IMAGE_POSTPROCESS_COMMAND += " generate_uboot_image; "
IMAGE_ROOTFS_SIZE = "65535"
INITRAMFS_MAXSIZE = "262144"

do_prepare_domd_boot_artifacts() {
    local initramfs_src

    install -d ${DOMD_DEPLOY_DIR}

    if [ ! -e "${DOMD_DEPLOY_DIR}/${XT_DOMD_DTB_NAME}" ]; then
        dtb_src=$(ls -1 "${DOMD_DEPLOY_DIR}/${XT_DOMD_DTB_NAME%.dtb}--"*.dtb 2>/dev/null | head -n1 || true)
        if [ -n "${dtb_src}" ]; then
            ln -sf "$(basename "${dtb_src}")" "${DOMD_DEPLOY_DIR}/${XT_DOMD_DTB_NAME}"
        fi
    fi

    if [ ! -e "${DOMD_DEPLOY_DIR}/Image" ] && [ -e "${DOMD_DEPLOY_DIR}/Image-${DOMD_MACHINE}.bin" ]; then
        ln -sf "Image-${DOMD_MACHINE}.bin" "${DOMD_DEPLOY_DIR}/Image"
    fi

    if [ ! -e "${DOMD_DEPLOY_DIR}/${DOMD_INITRAMFS_DEPLOY_NAME}" ]; then
        initramfs_src=$(ls -1 "${DOMD_DEPLOY_DIR}/initramfs"*.cpio.gz 2>/dev/null | head -n1 || true)
        if [ -n "${initramfs_src}" ]; then
            ln -sf "$(basename "${initramfs_src}")" "${DOMD_DEPLOY_DIR}/${DOMD_INITRAMFS_DEPLOY_NAME}"
        fi
    fi
}
addtask do_prepare_domd_boot_artifacts before do_rootfs after do_prepare_recipe_sysroot

do_prepare_domd_fit_inputs() {
    :
}
addtask do_prepare_domd_fit_inputs before do_image_complete after do_copy_files

install_domd_boot_artifacts() {
    domd_dtb=""
    domd_kernel=""
    domd_initramfs=""

    install -d ${IMAGE_ROOTFS}${libdir}/xen/boot

    for f in \
        ${DOMD_DEPLOY_DIR}/${XT_DOMD_DTB_NAME} \
        ${DOMD_DEPLOY_DIR}/${XT_DOMD_DTB_NAME%.dtb}--*.dtb; do
        [ -e "$f" ] || continue
        domd_dtb="$f"
        break
    done

    for f in \
        ${DOMD_DEPLOY_DIR}/Image \
        ${DOMD_DEPLOY_DIR}/Image-${DOMD_MACHINE}.bin; do
        [ -e "$f" ] || continue
        domd_kernel="$f"
        break
    done

    for f in \
        ${DOMD_DEPLOY_DIR}/${DOMD_INITRAMFS_DEPLOY_NAME} \
        ${DOMD_DEPLOY_DIR}/initramfs-image-${DOMD_MACHINE}.cpio.gz \
        ${DOMD_DEPLOY_DIR}/initramfs-*.cpio.gz; do
        [ -e "$f" ] || continue
        domd_initramfs="$f"
        break
    done

    [ -n "${domd_dtb}" ] || bbfatal "Missing DomD DTB under ${DOMD_DEPLOY_DIR}"
    [ -n "${domd_kernel}" ] || bbfatal "Missing DomD kernel Image under ${DOMD_DEPLOY_DIR}"
    [ -n "${domd_initramfs}" ] || bbfatal "Missing DomD initramfs under ${DOMD_DEPLOY_DIR}"

    install -m 0644 "${domd_dtb}" ${IMAGE_ROOTFS}${libdir}/xen/boot/domd.dtb
    install -m 0644 "${domd_kernel}" ${IMAGE_ROOTFS}${libdir}/xen/boot/linux-domd
    install -m 0644 "${domd_initramfs}" ${IMAGE_ROOTFS}${libdir}/xen/boot/${DOMD_INITRAMFS_DEPLOY_NAME}

    for f in ${DOMD_DEPLOY_DIR}/*.dtbo; do
        [ -e "$f" ] || continue
        install -m 0644 "$f" ${IMAGE_ROOTFS}${libdir}/xen/boot/
    done
}

ROOTFS_POSTPROCESS_COMMAND += " install_domd_boot_artifacts; "

# do_unpack is not supported with inherit core-image.
# Thus, we need to copy file manually.
BBAPPEND_FILE_PATH := "${THISDIR}"
do_copy_files () {
    cp -f ${BBAPPEND_FILE_PATH}/files/fit-image.its -t ${WORKDIR}/
    cp -f ${BBAPPEND_FILE_PATH}/files/fit-image-extra.its -t ${WORKDIR}/
}
addtask do_copy_files before do_image_complete

append_bin_image() {
    local fit_dir="${TOPDIR}/tmp-dom0/deploy/images/${MACHINE}"
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
    cp -f ${DOMD_DEPLOY_DIR}/xen-${DOMD_MACHINE}.efi ./xen
    cp -f ${DOMD_DEPLOY_DIR}/xenpolicy-${DOMD_MACHINE} ./xenpolicy
    cp -f ${DOMD_DEPLOY_DIR}/${XT_XEN_DTB_NAME} ./xen.dtb
    cp -f ${DOMD_DEPLOY_DIR}/bl31-${DOMD_MACHINE}.bin ./bl31.bin

    echo "" > ./fit-image-extra.its

    append_bin_image zephyr_blinky.bin

    mkimage -f ./fit-image.its ${DEPLOY_DIR_IMAGE}/fitImage
}

IMAGE_POSTPROCESS_COMMAND += " generate_fit_image"

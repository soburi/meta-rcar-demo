FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

RDEPENDS:${PN}:append = " dtc"
DOMD_DEPLOY_DIR = "${TOPDIR}/tmp-domd/deploy/images/${DOMD_MACHINE}"
DOMD_INITRAMFS_DEPLOY_NAME = "initramfs-domd.cpio.gz"
DOMD_MCDEP_PREFIX = "mc:dom0:domd"

do_install[mcdepends] += " \
    ${DOMD_MCDEP_PREFIX}:virtual/kernel:do_deploy \
    ${DOMD_MCDEP_PREFIX}:initramfs-image:do_image_complete \
"

SRC_URI:append = "\
    file://domd-set-root \
"
FILES:${PN}:append = " \
    ${libdir}/xen/bin/domd-set-root \
    ${libdir}/xen/boot/${DOMD_INITRAMFS_DEPLOY_NAME} \
    ${libdir}/xen/boot/*.dtbo \
"

CFG_FILE="${D}${sysconfdir}/xen/domd.cfg"

do_install() {
    domd_dtb=""
    domd_kernel=""
    domd_initramfs=""

    install -d ${D}${sysconfdir}/xen
    install -d ${D}${libdir}/xen/boot
    install -d ${D}${systemd_unitdir}/system
    install -d ${D}${libdir}/xen/bin

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

    install -m 0644 ${WORKDIR}/${XT_DOMD_CONFIG_NAME} ${D}${sysconfdir}/xen/domd.cfg
    install -m 0644 "${domd_dtb}" ${D}${libdir}/xen/boot/domd.dtb
    install -m 0644 "${domd_kernel}" ${D}${libdir}/xen/boot/linux-domd
    install -m 0644 "${domd_initramfs}" ${D}${libdir}/xen/boot/${DOMD_INITRAMFS_DEPLOY_NAME}
    install -m 0644 ${WORKDIR}/domd.service ${D}${systemd_unitdir}/system/
    install -m 0744 ${WORKDIR}/domd-set-root ${D}${libdir}/xen/bin

    for f in ${DOMD_DEPLOY_DIR}/*.dtbo; do
        [ -e "$f" ] || continue
        install -m 0644 "$f" ${D}${libdir}/xen/boot/
    done

    if ${@bb.utils.contains('DISTRO_FEATURES', 'enable_virtio', 'true', 'false', d)}; then
        echo "" >> ${CFG_FILE}
        echo "driver_domain = 1" >> ${CFG_FILE}

        if ${@bb.utils.contains('XT_GUEST_INSTALL', 'doma', 'true', 'false', d)}; then
            sed -i "s/\[VIRTIO_EXTRA_PARAMETERS\]/ vhost_xen.nogrant=1/g" ${CFG_FILE}
        else
            sed -i "s/\[VIRTIO_EXTRA_PARAMETERS\]/ vhost_xen.nogrant=0/g" ${CFG_FILE}
        fi
    else
        sed -i "s/\[VIRTIO_EXTRA_PARAMETERS\]//" ${CFG_FILE}
    fi

    # Call domd-set-root script before launching domain
    echo "[Service]" >> ${D}${systemd_unitdir}/system/domd.service
    echo "ExecStartPre=${libdir}/xen/bin/domd-set-root" >> ${D}${systemd_unitdir}/system/domd.service
}

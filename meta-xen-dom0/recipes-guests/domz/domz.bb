SUMMARY = "Zephyr guest images for Dom0 initramfs"
DESCRIPTION = "Install Zephyr guest binaries and Xen guest configs into the Dom0 initramfs"

PV = "0.1"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"

inherit systemd

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI = "\
    file://zephyr_blinky.conf \
    file://zephyr_can_echoback.conf \
    file://zephyr_vhost_blk.conf \
    file://zephyr_virtio_blk.conf \
    file://domz.service \
"

S = "${WORKDIR}"
PACKAGE_ARCH = "${MACHINE_ARCH}"

FILES:${PN} = " \
    ${sysconfdir}/xen/zephyr_blinky.conf \
    ${libdir}/xen/boot/zephyr_blinky.bin \
    ${sysconfdir}/xen/zephyr_can_echoback.conf \
    ${libdir}/xen/boot/zephyr_can_echoback.bin \
    ${sysconfdir}/xen/zephyr_vhost_blk.conf \
    ${libdir}/xen/boot/zephyr_vhost_blk.bin \
    ${sysconfdir}/xen/zephyr_virtio_blk.conf \
    ${libdir}/xen/boot/zephyr_virtio_blk.bin \
    ${systemd_unitdir}/system/domz.service \
"

SYSTEMD_SERVICE:${PN} = "domz.service"
SYSTEMD_AUTO_ENABLE:${PN} = "enable"

do_install[depends] += " \
    zephyr-blinky:do_deploy \
    zephyr-can-echoback:do_deploy \
    zephyr-vhost-blk:do_deploy \
    zephyr-virtio-blk:do_deploy \
"

do_install() {
    install -d ${D}${sysconfdir}/xen
    install -d ${D}${libdir}/xen/boot

    install -m 0644 ${WORKDIR}/zephyr_blinky.conf ${D}${sysconfdir}/xen/zephyr_blinky.conf
    install -m 0644 ${DEPLOY_DIR_IMAGE}/zephyr_blinky.bin ${D}${libdir}/xen/boot/zephyr_blinky.bin

    install -m 0644 ${WORKDIR}/zephyr_can_echoback.conf ${D}${sysconfdir}/xen/zephyr_can_echoback.conf
    install -m 0644 ${DEPLOY_DIR_IMAGE}/zephyr_can_echoback.bin ${D}${libdir}/xen/boot/zephyr_can_echoback.bin

    install -m 0644 ${WORKDIR}/zephyr_vhost_blk.conf ${D}${sysconfdir}/xen/zephyr_vhost_blk.conf
    install -m 0644 ${DEPLOY_DIR_IMAGE}/zephyr_vhost_blk.bin ${D}${libdir}/xen/boot/zephyr_vhost_blk.bin

    install -m 0644 ${WORKDIR}/zephyr_virtio_blk.conf ${D}${sysconfdir}/xen/zephyr_virtio_blk.conf
    install -m 0644 ${DEPLOY_DIR_IMAGE}/zephyr_virtio_blk.bin ${D}${libdir}/xen/boot/zephyr_virtio_blk.bin

    install -d ${D}${systemd_unitdir}/system
    install -m 0644 ${WORKDIR}/domz.service ${D}${systemd_unitdir}/system/
}

RDEPENDS:${PN}:append = " \
    backend-ready \
    launch-domain \
"

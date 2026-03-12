SUMMARY = "Zephyr guest images for Dom0 initramfs"
DESCRIPTION = "Install Zephyr guest binaries and Xen guest configs into the Dom0 initramfs"

PV = "0.1"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI = "\
    file://zephyr_blinky.conf \
    file://zephyr_blinky2.conf \
"

S = "${WORKDIR}"
PACKAGE_ARCH = "${MACHINE_ARCH}"
ZEPHYR_MC_MACHINE = "sparrow-hawk"
ZEPHYR_MC_DEPLOY_DIR = "${TOPDIR}/tmp/deploy/images/${ZEPHYR_MC_MACHINE}"

FILES:${PN} = " \
    ${sysconfdir}/xen/zephyr_blinky.conf \
    ${sysconfdir}/xen/zephyr_blinky2.conf \
    ${libdir}/xen/boot/zephyr_blinky.bin \
    ${libdir}/xen/boot/zephyr_blinky2.bin \
"

do_install[mcdepends] += " \
    mc:dom0::zephyr-blinky:do_deploy \
    mc:dom0::zephyr-blinky2:do_deploy \
"

do_install() {
    install -d ${D}${sysconfdir}/xen
    install -d ${D}${libdir}/xen/boot

    install -m 0644 ${WORKDIR}/zephyr_blinky.conf ${D}${sysconfdir}/xen/zephyr_blinky.conf
    install -m 0644 ${WORKDIR}/zephyr_blinky2.conf ${D}${sysconfdir}/xen/zephyr_blinky2.conf
    install -m 0644 ${ZEPHYR_MC_DEPLOY_DIR}/zephyr_blinky.bin ${D}${libdir}/xen/boot/zephyr_blinky.bin
    install -m 0644 ${ZEPHYR_MC_DEPLOY_DIR}/zephyr_blinky2.bin ${D}${libdir}/xen/boot/zephyr_blinky2.bin
}

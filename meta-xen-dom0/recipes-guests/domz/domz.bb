SUMMARY = "Zephyr guest images for Dom0 initramfs"
DESCRIPTION = "Install Zephyr guest binaries and Xen guest configs into the Dom0 initramfs"

PV = "0.1"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI = "\
    file://zephyr_blinky.conf \
"

S = "${WORKDIR}"
PACKAGE_ARCH = "${MACHINE_ARCH}"

FILES:${PN} = " \
    ${sysconfdir}/xen/zephyr_blinky.conf \
    ${libdir}/xen/boot/zephyr_blinky.bin \
"

do_install[depends] += " \
    zephyr-blinky:do_deploy \
"

do_install() {
    install -d ${D}${sysconfdir}/xen
    install -d ${D}${libdir}/xen/boot

    install -m 0644 ${WORKDIR}/zephyr_blinky.conf ${D}${sysconfdir}/xen/zephyr_blinky.conf
    install -m 0644 ${DEPLOY_DIR_IMAGE}/zephyr_blinky.bin ${D}${libdir}/xen/boot/zephyr_blinky.bin
}

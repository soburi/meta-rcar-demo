SUMMARY = "Zephyr guest images for Dom0 initramfs"
DESCRIPTION = "Install Zephyr guest binaries and Xen guest configs into the Dom0 initramfs"

PV = "0.1"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"

inherit externalsrc systemd
EXTERNALSRC_SYMLINKS = ""

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI = "\
    file://domz.cfg \
    file://domz.service \
"

S = "${WORKDIR}"
PACKAGE_ARCH = "${MACHINE_ARCH}"

FILES:${PN} = " \
    ${sysconfdir}/xen/domz.cfg \
    ${systemd_unitdir}/system/domz.service \
    ${libdir}/xen/boot/zephyr.bin \
    ${libdir}/xen/boot/zephyr.dtb \
"
SYSTEMD_SERVICE:${PN} = "domz.service"

do_install() {
    install -d ${D}${sysconfdir}/xen
    install -d ${D}${libdir}/xen/boot

    install -m 0644 ${WORKDIR}/domz.cfg ${D}${sysconfdir}/xen/domz.cfg
    install -m 0644 ${S}/build/zephyr/zephyr.bin ${D}${libdir}/xen/boot/zephyr.bin
    install -m 0644 ${S}/build/zephyr/zephyr.dtb ${D}${libdir}/xen/boot/zephyr.dtb

    install -d ${D}${systemd_unitdir}/system
    install -m 0644 ${WORKDIR}/domz.service ${D}${systemd_unitdir}/system/
}

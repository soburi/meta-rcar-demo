SUMMARY = "Xen DTB for Sparrow Hawk dom0"
LICENSE = "GPL-2.0-only"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/GPL-2.0-only;md5=801f80980d171dd6425610833a22dbe6"

COMPATIBLE_MACHINE = "sparrow-hawk"
PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit devicetree

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI = " \
    file://r8a779g3-sparrow-hawk-xen.dts \
    file://r8a779g3-xen-chosen.dtsi \
    file://r8a779g3-xen.dts \
"

DT_FILES = "r8a779g3-sparrow-hawk-xen.dts"

do_compile[depends] += "virtual/kernel:do_shared_workdir"

devicetree_do_deploy:append() {
    install -Dm 0644 ${B}/r8a779g3-sparrow-hawk-xen.dtb ${DEPLOYDIR}/${XT_XEN_DTB_NAME}
}


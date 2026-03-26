require xen-source.inc

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

FILES:${PN}-test = "\
    ${libdir}/xen/bin/test-xenstore \
    ${libdir}/xen/bin/test-resource \
"

do_install:append() {
    rm -f ${D}/${libdir}/xen/bin/init-dom0less
    rm -f ${D}/${systemd_unitdir}/system/var-lib-xenstored.mount
    rm -rf ${D}/var
}

FILES:${PN}-xencommons:remove = "\
    "${systemd_unitdir}/system/var-lib-xenstored.mount" \
"

SYSTEMD_SERVICE:${PN}-xencommons:remove = " \
    var-lib-xenstored.mount \
"

# Remove the recommendation for Qemu for non-hvm x86 added in meta-virtualization layer
RRECOMMENDS:${PN}:remove = "qemu"

# Avoid redundant runtime dependency on python3-core
RDEPENDS:${PN}:remove:class-target = "${PYTHON_PN}-core"

DEPENDS:remove = "pixman virtual/libsdl"

SRC_URI:remove = "file://0001-arm-Change-GUEST_GICV3_ITS_BASE.patch"
SRC_URI:remove = "file://0001-pci-Add-support-for-V4H-pcie-host.patch"

FILES:${PN} += "/var/lib /usr/lib/xen/bin/* /boot/*"

SYSTEMD_SERVICE:xen-tools:remove = "systemd-remount-fs.service"

SRC_URI:append = " file://0001-XSM-Add-domZ-policy.patch"

###
# TEMPORARY HACK
SRC_URI:append = " file://hack-xdg_runtime_dir.conf"
FILES:${PN}-devd += " ${sysconfdir}/systemd/system/xendriverdomain.service.d/hack-xdg_runtime_dir.conf"
do_install:append() {
    # Install drop-in file to define required environment variable
    install -d ${D}${sysconfdir}/systemd/system/xendriverdomain.service.d/
    install -m 0644 ${WORKDIR}/hack-xdg_runtime_dir.conf ${D}${sysconfdir}/systemd/system/xendriverdomain.service.d
}
# END OF TEMPORARY HACK
###

# Add addtional fixes
include ${@bb.utils.contains('XEN_REV', '2011e6c6fd35f564444983331296f5df7d154373', 'xen-tools_fixes.inc', '', d)}


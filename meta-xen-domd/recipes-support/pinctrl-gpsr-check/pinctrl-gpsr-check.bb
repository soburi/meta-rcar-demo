SUMMARY = "Inspect the live R-Car GPIO2 mux state"
DESCRIPTION = "Print the pinctrl debugfs entries and GPSR2 bits for GPIO2_0 through GPIO2_19."
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "file://check-gpio2-13-mux"

S = "${WORKDIR}"

RDEPENDS:${PN} = "devmem2"

do_install() {
    install -Dm 0755 ${WORKDIR}/check-gpio2-13-mux \
        ${D}${bindir}/check-gpio2-13-mux
    ln -s check-gpio2-13-mux ${D}${bindir}/check-gpio2-mux
}

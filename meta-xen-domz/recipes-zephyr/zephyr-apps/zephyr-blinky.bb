SUMMARY = "Build Zephyr blinky guest"
PV = "0.1"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${S}/zephyr/LICENSE;md5=fa818a259cbed7ce8bc2a22d35a464fc"

SRC_URI = "${ZEPHYR_APP_SOURCE_URI};name=app;destsuffix=git/zephyr-blinky \
           ${ZEPHYR_SOURCE_URI};name=zephyr;destsuffix=git/zephyr \
"
SRCREV_app = "8588f2dd6d701dadc60147b9a36575a90527174fb"
SRCREV_zephyr = "dc034d279e64f43085990d123db5ed5b40e6a634"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

ZEPHYR_SRC_DIR = "${S}/zephyr-blinky"
ZEPHYR_BOARD = "xenvm/xenvm/gicv3"
ZEPHYR_SNIPPETS = "sparrowhawk_rcar_v4h_xen_domd"
ZEPHYR_MODULES:append = "\;${S}/modules/lib/zephyr-xenlib"
ZEPHYR_IMAGE_LINK_NAME = "zephyr_blinky"
ZEPHYR_APP_SOURCE_URI = "git://github.com/soburi/zephyr-blinky.git;branch=sodev;protocol=https"
ZEPHYR_SOURCE_URI = "git://github.com/automotive-grade-linux/zephyr.git;branch=sparrowhawk-gpio-demo;protocol=https"

require zephyr-apps-common.inc

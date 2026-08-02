SUMMARY = "Build Zephyr blinky guest"
PV = "0.1"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${S}/zephyr/LICENSE;md5=fa818a259cbed7ce8bc2a22d35a464fc"

SRC_URI = "${ZEPHYR_APP_SOURCE_URI};name=app;destsuffix=git/zephyr-blinky \
           ${ZEPHYR_SOURCE_URI};name=zephyr;destsuffix=git/zephyr \
"
SRCREV_app = "4568be36279bebb80c91dbe5f2ea805a8abf5fc3"
SRCREV_zephyr = "30d5fd4f2f1d809810d5e23f8397b9d2396bfc86"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

ZEPHYR_SRC_DIR = "${S}/zephyr-app"
ZEPHYR_BOARD = "sparrowhawk_rcar_v4h/r8a779g0/a76"
ZEPHYR_SNIPPETS = "xen-guest"
ZEPHYR_IMAGE_LINK_NAME = "zephyr_blinky"
ZEPHYR_APP_SOURCE_URI = "git://github.com/soburi/zephyr-blinky.git;branch=sodev-coscup;protocol=https"
ZEPHYR_SOURCE_URI = "git://github.com/automotive-grade-linux/zephyr.git;branch=sparrowhawk-can-demo;protocol=https"

require zephyr-apps-common.inc

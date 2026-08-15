SUMMARY = "Build Zephyr can-echoback guest"
PV = "0.1"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${S}/zephyr/LICENSE;md5=fa818a259cbed7ce8bc2a22d35a464fc"

SRC_URI = "${ZEPHYR_APP_SOURCE_URI};name=app;destsuffix=git/zephyr-can-echoback \
           ${ZEPHYR_SOURCE_URI};name=zephyr;destsuffix=git/zephyr \
"
SRCREV_app = "7242817a895f535c9bec600f90c6c1d6b5c898a1"
SRCREV_zephyr = "85a53a2b5a3a4608aba237f7762334591c46db7f"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

ZEPHYR_SRC_DIR = "${S}/zephyr-app"
ZEPHYR_BOARD = "sparrowhawk_rcar_v4h/r8a779g0/a76"
ZEPHYR_SNIPPETS = "xen-guest"
ZEPHYR_IMAGE_LINK_NAME = "zephyr_can_echoback"
ZEPHYR_APP_SOURCE_URI = "git://github.com/soburi/zephyr-can-echoback.git;branch=sodev;protocol=https"
ZEPHYR_SOURCE_URI = "git://github.com/soburi/zephyr.git;branch=sparrowhawk-can-demo;protocol=https"

require zephyr-apps-common.inc

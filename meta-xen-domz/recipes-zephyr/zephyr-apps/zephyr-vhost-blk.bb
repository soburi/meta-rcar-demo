SUMMARY = "Build Zephyr vhost-blk guest"
PV = "0.1"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${S}/zephyr/LICENSE;md5=fa818a259cbed7ce8bc2a22d35a464fc"

SRC_URI = "${ZEPHYR_APP_SOURCE_URI};name=app;destsuffix=git/zephyr-vhost-blk \
           ${ZEPHYR_SOURCE_URI};name=zephyr;destsuffix=git/zephyr \
"
SRCREV_app = "c717a2e3c10780b3dceef3bc9403cd63eda2fb45"
SRCREV_zephyr = "b66599ee359ec887ccae53efef65118d482f7e0b"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

ZEPHYR_SRC_DIR = "${S}/zephyr-app"
ZEPHYR_BOARD = "sparrowhawk_rcar_v4h/r8a779g0/a76"
ZEPHYR_SNIPPETS = "xen-guest"
ZEPHYR_IMAGE_LINK_NAME = "zephyr_vhost_blk"
ZEPHYR_APP_SOURCE_URI = "git://github.com/soburi/zephyr-vhost-blk.git;branch=main;protocol=https"
ZEPHYR_SOURCE_URI = "git://github.com/soburi/zephyr.git;branch=sh-v4h-sodev3;protocol=https"

require zephyr-apps-common.inc

ZEPHYR_EXTRA_MODULES = "${S}/modules/lib/zephyr-xenlib"

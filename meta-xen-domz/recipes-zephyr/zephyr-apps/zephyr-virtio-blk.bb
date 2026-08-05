SUMMARY = "Build Zephyr virtio-blk guest"
PV = "0.1"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${S}/zephyr/LICENSE;md5=fa818a259cbed7ce8bc2a22d35a464fc"

SRC_URI = "${ZEPHYR_APP_SOURCE_URI};name=app;destsuffix=git/zephyr-vhost-blk \
           ${ZEPHYR_SOURCE_URI};name=zephyr;destsuffix=git/zephyr \
"
SRCREV_app = "db2db134a83f4f46b57d2fdee113b6ed607391bb"
SRCREV_zephyr = "b66599ee359ec887ccae53efef65118d482f7e0b"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

ZEPHYR_SRC_DIR = "${S}/zephyr-app"
ZEPHYR_BOARD = "xenvm//gicv3"
ZEPHYR_IMAGE_LINK_NAME = "zephyr_virtio_blk"
ZEPHYR_APP_SOURCE_URI = "git://github.com/soburi/zephyr-virtio-blk.git;branch=main;protocol=https"
ZEPHYR_SOURCE_URI = "git://github.com/soburi/zephyr.git;branch=sh-v4h-sodev3;protocol=https"

require zephyr-apps-common.inc

ZEPHYR_EXTRA_MODULES = "${S}/modules/lib/zephyr-xenlib"

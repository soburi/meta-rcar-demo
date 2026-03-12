SUMMARY = "Build Zephyr guest binary"
DESCRIPTION = "Build a Zephyr guest binary in the zephyr multiconfig and deploy it for Dom0"

inherit zephyr-sample python3native

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

ZEPHYR_APP_SOURCE_URI ?= "git://github.com/soburi/zephyr-blinky.git;branch=master;protocol=https"
ZEPHYR_SOURCE_URI ?= "git://github.com/soburi/zephyr.git;branch=sparrowhawk-demo-sodev;protocol=https"
SRC_URI = "${ZEPHYR_APP_SOURCE_URI};name=app;destsuffix=git/zephyr-blinky \
    ${ZEPHYR_SOURCE_URI};name=default;destsuffix=git/zephyr \
    git://github.com/zephyrproject-rtos/acpica.git;protocol=https;name=acpica;nobranch=1;destsuffix=git/modules/lib/acpica \
    git://github.com/zephyrproject-rtos/cmsis.git;protocol=https;name=cmsis;nobranch=1;destsuffix=git/modules/hal/cmsis \
    git://github.com/zephyrproject-rtos/cmsis-dsp.git;protocol=https;name=cmsisdsp;nobranch=1;destsuffix=git/modules/lib/cmsis-dsp \
    git://github.com/zephyrproject-rtos/cmsis-nn.git;protocol=https;name=cmsisnn;nobranch=1;destsuffix=git/modules/lib/cmsis-nn \
    git://github.com/zephyrproject-rtos/CMSIS_6.git;protocol=https;name=cmsis6;nobranch=1;destsuffix=git/modules/hal/cmsis_6 \
    git://github.com/zephyrproject-rtos/edtt.git;protocol=https;name=edtt;nobranch=1;destsuffix=git/tools/edtt \
    git://github.com/zephyrproject-rtos/fatfs.git;protocol=https;name=fatfs;nobranch=1;destsuffix=git/modules/fs/fatfs \
    git://github.com/zephyrproject-rtos/hal_renesas.git;protocol=https;name=halrenesas;nobranch=1;destsuffix=git/modules/hal/renesas \
    git://github.com/zephyrproject-rtos/liblc3.git;protocol=https;name=liblc3;nobranch=1;destsuffix=git/modules/lib/liblc3 \
    git://github.com/zephyrproject-rtos/libmctp.git;protocol=https;name=libmctp;nobranch=1;destsuffix=git/modules/lib/libmctp \
    git://github.com/zephyrproject-rtos/libmetal.git;protocol=https;name=libmetal;nobranch=1;destsuffix=git/modules/hal/libmetal \
    git://github.com/zephyrproject-rtos/libsbc.git;protocol=https;name=libsbc;nobranch=1;destsuffix=git/modules/lib/libsbc \
    git://github.com/zephyrproject-rtos/littlefs.git;protocol=https;name=littlefs;nobranch=1;destsuffix=git/modules/fs/littlefs \
    git://github.com/zephyrproject-rtos/lora-basics-modem.git;protocol=https;name=lorabasics;nobranch=1;destsuffix=git/modules/lib/lora-basics-modem \
    git://github.com/zephyrproject-rtos/mbedtls.git;protocol=https;name=mbedtls;nobranch=1;destsuffix=git/modules/crypto/mbedtls \
    git://github.com/zephyrproject-rtos/mcuboot.git;protocol=https;name=mcuboot;nobranch=1;destsuffix=git/bootloader/mcuboot \
    git://github.com/zephyrproject-rtos/mipi-sys-t.git;protocol=https;name=mipisyst;nobranch=1;destsuffix=git/modules/debug/mipi-sys-t \
    git://github.com/zephyrproject-rtos/nanopb.git;protocol=https;name=nanopb;nobranch=1;destsuffix=git/modules/lib/nanopb \
    git://github.com/zephyrproject-rtos/net-tools.git;protocol=https;name=nettools;nobranch=1;destsuffix=git/tools/net-tools \
    git://github.com/zephyrproject-rtos/open-amp.git;protocol=https;name=openamp;nobranch=1;destsuffix=git/modules/lib/open-amp \
    git://github.com/zephyrproject-rtos/openthread.git;protocol=https;name=openthread;nobranch=1;destsuffix=git/modules/lib/openthread \
    git://github.com/zephyrproject-rtos/picolibc.git;protocol=https;name=picolibc;nobranch=1;destsuffix=git/modules/lib/picolibc \
    git://github.com/zephyrproject-rtos/segger.git;protocol=https;name=segger;nobranch=1;destsuffix=git/modules/debug/segger \
    git://github.com/zephyrproject-rtos/trusted-firmware-a.git;protocol=https;name=tfa;nobranch=1;destsuffix=git/modules/tee/tf-a/trusted-firmware-a \
    git://github.com/zephyrproject-rtos/trusted-firmware-m.git;protocol=https;name=tfm;nobranch=1;destsuffix=git/modules/tee/tf-m/trusted-firmware-m \
    git://github.com/zephyrproject-rtos/uoscore-uedhoc.git;protocol=https;name=uedhoc;nobranch=1;destsuffix=git/modules/lib/uoscore-uedhoc \
    git://github.com/zephyrproject-rtos/zcbor.git;protocol=https;name=zcbor;nobranch=1;destsuffix=git/modules/lib/zcbor \
    git://github.com/soburi/zephyr-xenlib.git;protocol=https;branch=xs-client;name=xenlib;destsuffix=git/modules/lib/zephyr-xenlib \
    file://zephyr_blinky.conf \
    file://zephyr_blinky.overlay \
"

SRCREV_app = "52ccb98ee924390a15120acd64cdb87fafce9c37"
SRCREV_default = "dc034d279e64f43085990d123db5ed5b40e6a634"
SRCREV_acpica = "8d24867bc9c9d81c81eeac59391cda59333affd4"
SRCREV_cmsis = "512cc7e895e8491696b61f7ba8066b4a182569b8"
SRCREV_cmsisdsp = "97512610ec92058f0119450b9e743eeb7e95b5c8"
SRCREV_cmsisnn = "e9328d612ea3ea7d0d210d3ac16ea8667c01abdd"
SRCREV_cmsis6 = "30a859f44ef8ab4dc8f84b03ed586fd16ccf9d74"
SRCREV_edtt = "c282625e694f0b53ea53e13231ea6d2f49411768"
SRCREV_fatfs = "f4ead3bf4a6dab3a07d7b5f5315795c073db568d"
SRCREV_halrenesas = "a279c14e196cb0904593035888a334dcd2c720bd"
SRCREV_liblc3 = "48bbd3eacd36e99a57317a0a4867002e0b09e183"
SRCREV_libmctp = "b97860e78998551af99931ece149eeffc538bdb1"
SRCREV_libmetal = "91d38634d1882f0a2151966f8c5c230ce1c0de7b"
SRCREV_libsbc = "8e1beda02acb8972e29e6edbb423f7cafe16e445"
SRCREV_littlefs = "8f5ca347843363882619d8f96c00d8dbd88a8e79"
SRCREV_lorabasics = "9a14f6772c1d6e303bacb2d594c8063bb804b6ee"
SRCREV_mbedtls = "c5b06d89c9c498d8fc8659ce31f7e53137b6270f"
SRCREV_mcuboot = "f3cc9476e233364031e9ab842290392f260fba82"
SRCREV_mipisyst = "5a9d6055b62edc54566d6d0034d9daec91749b98"
SRCREV_nanopb = "5499fd4c9a478f8139eeb07a82c3b4468d6067f7"
SRCREV_nettools = "64d7acc661ae2772282570f21beab85d02f2f35c"
SRCREV_openamp = "c30a6d8b92fcebdb797fc1a7698e8729e250f637"
SRCREV_openthread = "2bc7712f57af22058770d1ef131ad3da79a0c764"
SRCREV_picolibc = "ca8b6ebba5226a75545e57a140443168a26ba664"
SRCREV_segger = "9f08435a79d41133d7046b7c59d1b25929eda450"
SRCREV_tfa = "0a29cac8fe0f7bdb835b469d9ea11b8e17377a92"
SRCREV_tfm = "04aa7243e04946b5422b124bea9c0675ab6b120f"
SRCREV_uedhoc = "54abc109c9c0adfd53c70077744c14e454f04f4a"
SRCREV_zcbor = "9b07780aca6fb21f82a241ba386ad9b379809337"
SRCREV_xenlib = "2f9cd644f7d05b59297954958a5ce4e0edca93b4"
SRCREV_FORMAT = "default"

ZEPHYR_SRC_DIR = "${S}/zephyr-blinky"
ZEPHYR_BOARD = "xenvm/xenvm/gicv3"
ZEPHYR_MODULES:append = "\;${S}/modules/lib/zephyr-xenlib"
ZEPHYR_IMAGE_LINK_NAME ?= "zephyr_blinky"

EXTRA_OECMAKE:append = " \
    -DOVERLAY_CONFIG=${WORKDIR}/zephyr_blinky.conf \
    -DDTC_OVERLAY_FILE=${WORKDIR}/zephyr_blinky.overlay \
    -DEXTRA_CFLAGS=-mno-outline-atomics \
"

DEPENDS:append = " python3-jsonschema-native dtc-native"
PACKAGE_ARCH = "${MACHINE_ARCH}"

python () {
    current_mc = d.getVar("BB_CURRENT_MC") or ""
    if current_mc not in ("", "default"):
        raise bb.parse.SkipRecipe("Only available in the default build context")
}

do_configure:prepend() {
    cd ${WORKDIR}
    rm -rf ${B}
    install -d ${B}
    cd ${B}
    install -d ${HOME}
    install -d ${TMPDIR}
}

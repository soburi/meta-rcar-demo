inherit zephyr-sample python3native

SRC_URI = "\
    ${ZEPHYR_APP_SOURCE_URI};name=app;destsuffix=git/zephyr-blinky \
    ${ZEPHYR_SOURCE_URI};name=zephyr;destsuffix=git/zephyr \
    git://github.com/zephyrproject-rtos/cmsis.git;protocol=https;name=cmsis;nobranch=1;destsuffix=git/modules/hal/cmsis \
    git://github.com/zephyrproject-rtos/CMSIS_6.git;protocol=https;name=cmsis6;nobranch=1;destsuffix=git/modules/hal/cmsis_6 \
    git://github.com/zephyrproject-rtos/hal_renesas.git;protocol=https;name=halrenesas;nobranch=1;destsuffix=git/modules/hal/renesas \
    git://github.com/zephyrproject-rtos/mbedtls.git;protocol=https;name=mbedtls;nobranch=1;destsuffix=git/modules/crypto/mbedtls \
    git://github.com/zephyrproject-rtos/mcuboot.git;protocol=https;name=mcuboot;nobranch=1;destsuffix=git/bootloader/mcuboot \
    git://github.com/zephyrproject-rtos/net-tools.git;protocol=https;name=nettools;nobranch=1;destsuffix=git/tools/net-tools \
    git://github.com/zephyrproject-rtos/open-amp.git;protocol=https;name=openamp;nobranch=1;destsuffix=git/modules/lib/open-amp \
    git://github.com/zephyrproject-rtos/picolibc.git;protocol=https;name=picolibc;nobranch=1;destsuffix=git/modules/lib/picolibc \
    git://github.com/zephyrproject-rtos/trusted-firmware-a.git;protocol=https;name=tfa;nobranch=1;destsuffix=git/modules/tee/tf-a/trusted-firmware-a \
    git://github.com/zephyrproject-rtos/trusted-firmware-m.git;protocol=https;name=tfm;nobranch=1;destsuffix=git/modules/tee/tf-m/trusted-firmware-m \
    git://github.com/zephyrproject-rtos/uoscore-uedhoc.git;protocol=https;name=uedhoc;nobranch=1;destsuffix=git/modules/lib/uoscore-uedhoc \
    git://github.com/soburi/zephyr-xenlib.git;protocol=https;branch=xs-client;name=xenlib;destsuffix=git/modules/lib/zephyr-xenlib \
"

SRCREV_app = "b17730e28ded3ef47e3ff4f277a03904cc1cd3a2"
SRCREV_cmsis = "512cc7e895e8491696b61f7ba8066b4a182569b8"
SRCREV_cmsis6 = "30a859f44ef8ab4dc8f84b03ed586fd16ccf9d74"
SRCREV_halrenesas = "a279c14e196cb0904593035888a334dcd2c720bd"
SRCREV_mbedtls = "c5b06d89c9c498d8fc8659ce31f7e53137b6270f"
SRCREV_mcuboot = "f3cc9476e233364031e9ab842290392f260fba82"
SRCREV_nettools = "64d7acc661ae2772282570f21beab85d02f2f35c"
SRCREV_openamp = "c30a6d8b92fcebdb797fc1a7698e8729e250f637"
SRCREV_picolibc = "ca8b6ebba5226a75545e57a140443168a26ba664"
SRCREV_tfa = "0a29cac8fe0f7bdb835b469d9ea11b8e17377a92"
SRCREV_tfm = "04aa7243e04946b5422b124bea9c0675ab6b120f"
SRCREV_uedhoc = "54abc109c9c0adfd53c70077744c14e454f04f4a"
SRCREV_xenlib = "2f9cd644f7d05b59297954958a5ce4e0edca93b4"
SRCREV_FORMAT = "default"

DEPENDS:append = " python3-jsonschema-native dtc-native"
PACKAGE_ARCH = "${MACHINE_ARCH}"

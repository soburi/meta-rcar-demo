#!/bin/bash -eu

SCRIPT_DIR=$(cd `dirname $0` && pwd)
WORK_DIR=${SCRIPT_DIR}/work_v4hsbc_xen
mkdir -p ${WORK_DIR}
USE_GRAPHICS_PACKAGE=yes
ENABLE_ZEPHYR=no
CLEAN_BUILD_TEST=no
INHERIT_RM_WORK=no

Usage() {
    echo "Usage:"
    echo "    $0 [option]"
    echo "option:"
    echo "    -c: Clean Build test(Default is disable)"
    echo "    -r: Enable rm_work on Yocto build"
    echo "    -z: Build Zephyr images"
    echo "    -h: Show this usage"
}

# Proc arguments
OPTIND=1
while getopts "chrz" OPT
do
    case $OPT in
        c) CLEAN_BUILD_TEST=yes;;
        r) INHERIT_RM_WORK=yes;;
        z) ENABLE_ZEPHYR=yes;;
        h) Usage; exit;;
        *) echo -e "\e[31mERROR: Unsupported option\e[m"; Usage; exit;;
    esac
done

cd ${WORK_DIR}
cp -f ../prod-devel-rcar4_new.yaml ./

if [[ "${CLEAN_BUILD_TEST}" == "yes" ]]; then
    sed -i -e 's/"yocto"/"yocto-clean"/' ./prod-devel-rcar4_new.yaml
    rm -rf yocto-clean/build-dom*/conf
    rm -rf ./yocto-clean/build-dom*
fi

rm -rf yocto/build-dom*/conf
moulin prod-devel-rcar4_new.yaml \
    --MACHINE sparrow-hawk \
    --USE_GRAPHICS_PACKAGE ${USE_GRAPHICS_PACKAGE} \
    --ADD_META_TEST yes \
    --ENABLE_ZEPHYR ${ENABLE_ZEPHYR}

cd "${WORK_DIR}"

if [[ "${INHERIT_RM_WORK}" == "yes" ]]; then
    echo "apply rm_work"
    ../scripts/inherit_rm_work.sh
fi

ninja
ninja full.img
# if [[ "${USING_DOMA}" == "yes" ]]; then
#     ninja full.img.gz android_only.img.gz
# else
#     ninja full.img.gz
# fi


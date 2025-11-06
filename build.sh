#!/bin/bash -eu

SCRIPT_DIR=$(cd `dirname $0` && pwd)
WORK_DIR=${SCRIPT_DIR}/work_v4hsbc_xen
mkdir -p ${WORK_DIR}
USING_DOMA=no
USING_DOMU=no
USE_GRAPHICS_PACKAGE=no
ENABLE_VIRTIO=no
ENABLE_DOMU_VIRTIO=no
CLEAN_BUILD_TEST=no

CheckGraphicsPackage () {
    PROP_DIR=$SCRIPT_DIR/proprietary
    ITEM_LIST=("GSX_KM_V4H_SparrowHawk.tar.bz2" "r8a779g3_linux_gsx_binaries_gles.tar.bz2")
    for item in ${ITEM_LIST[@]}; do
        if [[ ! -e ${PROP_DIR}/${item} ]]; then
            echo "${PROP_DIR}/${item} is not found !!"
            exit -1
        fi
    done
}

Usage() {
    echo "Usage:"
    echo "    $0 [option]"
    echo "option:"
    echo "    -a: Using DomA(Default is disable. Virtio is forcely enabled.)"
    echo "    -c: Clean Build test(Default is disable)"
    echo "    -g: Use graphics package(Default is not used)"
    echo "    -u: Using DomU(Default is disable)"
    echo "    -v: Enable Virtio backend on DomD(Default is disabled)"
    echo "    -h: Show this usage"
}

# Proc arguments
OPTIND=1
while getopts "acghuv" OPT
do
    case $OPT in
        a) USING_DOMA=yes; ENABLE_VIRTIO=yes ;;
        c) CLEAN_BUILD_TEST=yes;;
        g) USE_GRAPHICS_PACKAGE=yes;;
        u) USING_DOMU=yes;;
        v) ENABLE_VIRTIO=yes;;
        h) Usage; exit;;
        *) echo -e "\e[31mERROR: Unsupported option\e[m"; Usage; exit;;
    esac
done
if [[ "${USING_DOMU}" == "yes" ]] && [[ "${ENABLE_VIRTIO}" == "yes" ]]; then
    ENABLE_DOMU_VIRTIO=yes
fi

cd ${WORK_DIR}
cp -f ../prod-devel-rcar4_new.yaml ./

# Check and copy graphics packages
if [[ ${USE_GRAPHICS_PACKAGE} == "yes" ]]; then
    CheckGraphicsPackage
fi

if [[ "${CLEAN_BUILD_TEST}" == "yes" ]]; then
    sed -i -e 's/"yocto"/"yocto-clean"/' ./prod-devel-rcar4_new.yaml
    rm -rf yocto-clean/build-dom*/conf
    rm -rf ./yocto-clean/build-dom*
fi

# repo command setup
if [[ ${USING_DOMA} == "yes" ]]; then
    curl https://storage.googleapis.com/git-repo-downloads/repo > repo
    chmod a+x ./repo
    export PATH=$PWD:$PATH
fi

rm -rf yocto/build-dom*/conf
moulin prod-devel-rcar4_new.yaml \
    --MACHINE sparrow-hawk \
    --ENABLE_ANDROID ${USING_DOMA} \
    --ENABLE_DOMU ${USING_DOMU} \
    --ENABLE_DOMU_VIRTIO ${ENABLE_DOMU_VIRTIO} \
    --USE_GRAPHICS_PACKAGE ${USE_GRAPHICS_PACKAGE} \
    --ENABLE_VIRTIO ${ENABLE_VIRTIO} \
    --ADD_META_TEST yes \

ninja
if [[ ${USING_DOMA} == "yes" ]]; then
    ninja full.img.gz android_only.img.gz
else
    ninja full.img.gz
fi

END_SECTOR=$(fdisk -l full.img | tail -2 | head -1 | awk '{print $3}')
dd if=full.img bs=512 count=$(( $END_SECTOR + 1 )) | gzip -c > domd_full.img.gz


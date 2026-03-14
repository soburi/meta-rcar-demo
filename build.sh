#!/bin/bash -eu

SCRIPT_DIR=$(cd `dirname $0` && pwd)
WORK_DIR=${SCRIPT_DIR}/work_v4hsbc_xen
mkdir -p ${WORK_DIR}
USING_DOMA=no
USING_DOMU=no
USE_GRAPHICS_PACKAGE=yes
ENABLE_VIRTIO=no
ENABLE_DOMU_VIRTIO=no
CLEAN_BUILD_TEST=no
INHERIT_RM_WORK=no
ENABLE_DOMU_AGL_IVI=undefined
ENABLE_DOMU_AGL_IC=undefined
ENABLE_ZEPHYR=no

Usage() {
    echo "Usage:"
    echo "    $0 [option]"
    echo "option:"
    echo "    -a, --doma: Using DomA(Default is disable. Virtio is forcely enabled.)"
    echo "    -c, --clean-build-test: Clean Build test(Default is disable)"
    echo "    -u, --domu: Using DomU(Default is disable)"
    echo "    -v, --virtio: Enable Virtio backend on DomD(Default is disabled)"
    echo "    -r, --rm-work: Enable rm_work on Yocto build"
    echo "    -z, --zephyr, --enable-zephyr: Build Zephyr images"
    echo "        --enable-domu-agl-ivi: Enable DomU AGL-IVI guest"
    echo "        --disable-domu-agl-ivi: Disable DomU AGL-IVI guest"
    echo "        --enable-domu-agl-ic: Enable DomU AGL-Cluster guest"
    echo "        --disable-domu-agl-ic: Disable DomU AGL-Cluster guest"
    echo "    -h, --help: Show this usage"
}

# Proc arguments
set_option() {
    case "$1" in
        a) USING_DOMA=yes; ENABLE_VIRTIO=yes ;;
        c) CLEAN_BUILD_TEST=yes ;;
        u) USING_DOMU=yes ;;
        v) ENABLE_VIRTIO=yes ;;
        r) INHERIT_RM_WORK=yes ;;
        z) ENABLE_ZEPHYR=yes ;;
        h) Usage; exit 0 ;;
        *) echo -e "\e[31mERROR: Unsupported option '-$1'\e[m"; Usage; exit 1 ;;
    esac
}

while [[ $# -gt 0 ]]
do
    case "$1" in
        --doma) set_option a ;;
        --clean-build-test) set_option c ;;
        --domu) set_option u ;;
        --virtio) set_option v ;;
        --rm-work) set_option r ;;
        --zephyr|--enable-zephyr) set_option z ;;
        --enable-domu-agl-ivi) ENABLE_DOMU_AGL_IVI=yes ;;
        --disable-domu-agl-ivi) ENABLE_DOMU_AGL_IVI=no ;;
        --enable-domu-agl-ic) ENABLE_DOMU_AGL_IC=yes ;;
        --disable-domu-agl-ic) ENABLE_DOMU_AGL_IC=no ;;
        --help) set_option h ;;
        --) shift; break ;;
        -[!-]?*)
            short_opts="${1#-}"
            for ((i=0; i<${#short_opts}; i++)); do
                set_option "${short_opts:i:1}"
            done
            ;;
        -?)
            set_option "${1#-}"
            ;;
        *)
            echo -e "\e[31mERROR: Unsupported argument '$1'\e[m"
            Usage
            exit 1
            ;;
    esac
    shift
done

if [[ $# -gt 0 ]]; then
    echo -e "\e[31mERROR: Unexpected positional arguments: $*\e[m"
    Usage
    exit 1
fi

if [[ "${USING_DOMU}" == "yes" ]] && [[ "${ENABLE_VIRTIO}" == "yes" ]]; then
    ENABLE_DOMU_VIRTIO=yes
fi

if [[ "${ENABLE_DOMU_AGL_IVI}" == "undefined" ]]; then
    ENABLE_DOMU_AGL_IVI=${USING_DOMU}
fi

if [[ "${ENABLE_DOMU_AGL_IC}" == "undefined" ]]; then
    ENABLE_DOMU_AGL_IC=${USING_DOMU}
fi

cd ${WORK_DIR}
cp -f ../prod-devel-rcar4_new.yaml ./

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


#
# sstate reuse can skip regenerating artifacts in the deploy phase, such as the "Image" symlink, breaking downstream builds.
# This checks artifact consistency and forces regeneration when needed, by explicitly running do_clean and do_deploy.
#

domd_regenerate_tasks=(virtual/kernel xen-tools u-boot ipl-burning)
domu_regenerate_tasks=(virtual/kernel)

if [ -d yocto/build-domd/conf ] && [ -d "yocto/build-domd/tmp/deploy/images/sparrow-hawk" ] && [ ! -e "yocto/build-domd/tmp/deploy/images/sparrow-hawk/Image" ]; then
    cd yocto
    bash -c "source poky/oe-init-build-env build-domd; bitbake -c clean ${domd_regenerate_tasks[*]}; bitbake -c deploy ${domd_regenerate_tasks[*]}"
    cd "${WORK_DIR}"
fi

if [ -d yocto/build-domu/conf ] && [ -d "yocto/build-domu/tmp/deploy/images/virtio-armv8-xt" ] && [ ! -e "yocto/build-domu/tmp/deploy/images/virtio-armv8-xt/Image" ]; then
    cd yocto
    bash -c "source poky/oe-init-build-env build-domu; bitbake -c clean ${domu_regenerate_tasks[*]}; bitbake -c deploy ${domu_regenerate_tasks[*]}"
    cd "${WORK_DIR}"
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
    --ENABLE_DOMU_AGL_IVI ${ENABLE_DOMU_AGL_IVI} \
    --ENABLE_DOMU_AGL_IC ${ENABLE_DOMU_AGL_IC} \
    --ENABLE_ZEPHYR ${ENABLE_ZEPHYR} \


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


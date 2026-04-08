generate_fit_image() {
    cd ${WORKDIR}
    cp -f ${DEPLOY_DIR_IMAGE}/Image ./Image
    cp -f ${IMGDEPLOYDIR}/${IMAGE_NAME}.cpio.gz ./uInitramfs
    cp -f ${DEPLOY_DIR_IMAGE}/xen-${MACHINE}.efi ./xen
    cp -f ${DEPLOY_DIR_IMAGE}/xenpolicy-${MACHINE} ./xenpolicy
    cp -f ${DEPLOY_DIR_IMAGE}/${XT_XEN_DTB_NAME} ./xen.dtb
    cp -f ${DEPLOY_DIR_IMAGE}/bl31-${MACHINE}.bin ./bl31.bin

    echo "" > ./fit-image-extra.its

    append_bin_image zephyr_blinky.bin

    mkimage -f ./fit-image.its ${DEPLOY_DIR_IMAGE}/fitImage
}

do_image_complete[depends] += " sparrow-hawk-xen-dtb:do_deploy"


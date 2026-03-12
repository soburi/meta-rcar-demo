IMAGE_INSTALL:append = " \
    xen \
    xen-tools-devd \
    xen-tools-scripts-network \
    xen-tools-scripts-block \
    xen-tools-xenstore \
    xen-tools-xencommons \
    xen-network \
    dnsmasq \
    nftables \
"

# For Xen-network
IMAGE_INSTALL:append = " \
    kernel-module-xt-masquerade \
    kernel-module-xt-nat \
    kernel-module-xt-tcpudp \
"

IMAGE_INSTALL:append = " \
    glmark2 \
    coreutils \
"

IMAGE_INSTALL:append = " \
    ${@bb.utils.contains('DISTRO_FEATURES', 'enable_virtio', ' qemu-system-aarch64 qemu-keymaps', '', d)} \
    block \
    ${@bb.utils.contains('DISTRO_FEATURES', 'enable_virtio wayland', ' virglrenderer libsdl2', '', d)} \
"

# Add package if DomA is available
IMAGE_INSTALL:append = " \
    ${@bb.utils.contains('XT_GUEST_INSTALL', 'doma', ' android-tools install-files-doma', '', d)} \
"

BBAPPEND_DIR := "${THISDIR}"

ROOTFS_POSTPROCESS_COMMAND += "install_udev_rules;"
install_udev_rules() {
    mkdir -p ${IMAGE_ROOTFS}/etc/udev/rules.d
    install -m 0755 ${BBAPPEND_DIR}/files/99-bind-input-devices.rules ${IMAGE_ROOTFS}/etc/udev/rules.d/
}

do_deploy_rootfs_ext4_link() {
    local src_ext4
    local src_pattern="${IMGDEPLOYDIR}/${IMAGE_LINK_NAME}-"*.ext4
    local dst_ext4="${DEPLOY_DIR_IMAGE}/${IMAGE_LINK_NAME}.ext4"

    src_ext4=$(ls -1t ${src_pattern} 2>/dev/null | head -n1 || true)
    if [ -z "${src_ext4}" ]; then
        if [ -e "${IMGDEPLOYDIR}/${IMAGE_LINK_NAME}.ext4" ]; then
            src_ext4="${IMGDEPLOYDIR}/${IMAGE_LINK_NAME}.ext4"
        else
            bbfatal "Missing core-image-weston ext4 source file. Looked for ${src_pattern} and ${IMGDEPLOYDIR}/${IMAGE_LINK_NAME}.ext4"
        fi
    fi

    rm -f "${dst_ext4}"
    ln -s "$(basename "${src_ext4}")" "${dst_ext4}"
}

addtask deploy_rootfs_ext4_link after do_image_complete before do_build

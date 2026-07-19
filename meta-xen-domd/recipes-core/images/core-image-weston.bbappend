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
    devmem2 \
    pinctrl-gpsr-check \
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

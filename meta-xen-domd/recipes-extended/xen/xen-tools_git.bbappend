
PACKAGECONFIG:append = " \
    xsm \
"

FILES:${PN}-flask = " \
    /boot/xenpolicy-${XEN_REL}* \
"

do_deploy:append() {
    if [ ! -e "${DEPLOYDIR}/xenpolicy-${MACHINE}" ] && [ -e "${DEPLOYDIR}/xenpolicy-${XEN_REL}" ]; then
        ln -sf xenpolicy-${XEN_REL} ${DEPLOYDIR}/xenpolicy-${MACHINE}
    fi
}

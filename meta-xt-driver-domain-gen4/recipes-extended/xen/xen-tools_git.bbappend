FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

PACKAGECONFIG:append = " \
    xsm \
"

FILES:${PN}-flask = " \
    /boot/xenpolicy-${XEN_REL}* \
"

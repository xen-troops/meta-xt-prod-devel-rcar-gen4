FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

PACKAGECONFIG:append = " \
    xsm \
"

FILES:${PN}-flask = " \
    /boot/xenpolicy-${XEN_REL}* \
"

SRC_URI:append = " \
    file://0001-arm-Change-GUEST_GICV3_ITS_BASE.patch \
"

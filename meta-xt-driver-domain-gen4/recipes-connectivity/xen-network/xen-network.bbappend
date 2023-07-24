FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += "\
    file://systemd-networkd-wait-online.conf \
    file://tsn0.network \
    file://tsn1.network \
    file://vmq0.network \
"

FILES_${PN} += " \
    ${sysconfdir}/systemd/network/tsn0.network \
    ${sysconfdir}/systemd/network/tsn1.network \
    ${sysconfdir}/systemd/network/vmq0.network \
"

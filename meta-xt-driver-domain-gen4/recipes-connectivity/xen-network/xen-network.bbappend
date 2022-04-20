FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SYSTEMD_SERVICE_${PN} = "bridge-up-notification.service"

SRC_URI += "\
    file://systemd-networkd-wait-online.conf \
    file://tsn0.network \
    file://vmq0.network \
"

FILES_${PN} += " \
    ${sysconfdir}/systemd/network/tsn0.network \
    ${sysconfdir}/systemd/network/vmq0.network \
"

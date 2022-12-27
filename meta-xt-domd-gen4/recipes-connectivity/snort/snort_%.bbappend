

SRC_URI += " file://snort-tsn0.service \
    file://snort-tsn1.service \
    file://snort-tsn2.service \
"

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"


do_install_append() {
    install -d ${D}${systemd_unitdir}/system
    install -m 0644 ${WORKDIR}/snort-tsn0.service ${D}${systemd_unitdir}/system/
    install -m 0644 ${WORKDIR}/snort-tsn1.service ${D}${systemd_unitdir}/system/
    install -m 0644 ${WORKDIR}/snort-tsn2.service ${D}${systemd_unitdir}/system/
}


SYSTEMD_PACKAGES = "snort-tsn0 snort-tsn1 snort-tsn2 "
SYSTEMD_SERVICE_snort-tsn0 = "snort-tsn0.service"
SYSTEMD_SERVICE_snort-tsn1 = "snort-tsn1.service"
SYSTEMD_SERVICE_snort-tsn2 = "snort-tsn2.service"

FILES_${PN} += " ${systemd_unitdir}/system/snort-tsn0.service \
    ${systemd_unitdir}/system/snort-tsn1.service \
    ${systemd_unitdir}/system/snort-tsn2.service \
"


PV = "2.9.20"
SRC_URI[md5sum] = ""
SRC_URI[sha256sum] = "29400e13f53b1831e0b8b10ec1224a1cbaa6dc1533a5322a20dd80bb84b4981c"

SRC_URI:remove = "file://configure.in-disable-tirpc-checking-for-fedora.patch"

SRC_URI += " file://snort-tsn0.service \
    file://snort-tsn1.service \
    file://configure.in-disable-tirpc-checking-for-fedora-snort-20.patch \
"

SRC_URI:append:spider = " \
    file://snort-tsn2.service \
"

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"


do_install:append() {
    install -d ${D}${systemd_unitdir}/system
    install -m 0644 ${WORKDIR}/snort-tsn0.service ${D}${systemd_unitdir}/system/
    install -m 0644 ${WORKDIR}/snort-tsn1.service ${D}${systemd_unitdir}/system/
    echo "config daq: rswitch_offload" >> ${D}/etc/snort/snort.conf
}

do_install:append:spider() {
    install -d ${D}${systemd_unitdir}/system
    install -m 0644 ${WORKDIR}/snort-tsn2.service ${D}${systemd_unitdir}/system/
}

PACKAGES:append = " snort-tsn0 snort-tsn1"
PACKAGES:append:spider = " snort-tsn2"

SYSTEMD_PACKAGES = "snort-tsn0 snort-tsn1"
SYSTEMD_PACKAGES:append:spider = " snort-tsn2"
SYSTEMD_SERVICE:snort-tsn0 = "snort-tsn0.service"
SYSTEMD_SERVICE:snort-tsn1 = "snort-tsn1.service"
SYSTEMD_SERVICE:snort-tsn2 = "snort-tsn2.service"

FILES:${PN} += " ${systemd_unitdir}/system/snort-tsn0.service \
    ${systemd_unitdir}/system/snort-tsn1.service \
"

FILES:${PN}:append:spider = " \
    ${systemd_unitdir}/system/snort-tsn2.service \
"


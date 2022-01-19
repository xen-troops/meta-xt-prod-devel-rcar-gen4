SUMMARY = "PV Net for Domain-0 setup"
DESCRIPTION = "Set up a para-virtualized networking in Domain-0"

PV = "0.1"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"

inherit externalsrc systemd

RDEPENDS_${PN} = "backend-ready"

SRC_URI += "\
    file://pvnet.service \
    file://10-eth0.network \
"

FILES_${PN} = " \
    ${systemd_unitdir}/system/pvnet.service \
    ${sysconfdir}/systemd/network/10-eth0.network \
"

SYSTEMD_SERVICE_${PN} = "pvnet.service"

do_install() {
    install -d ${D}${systemd_unitdir}/system
    install -m 0644 ${WORKDIR}/pvnet.service ${D}${systemd_unitdir}/system/

    install -d ${D}${sysconfdir}/systemd/network/
    install -m 0644 ${WORKDIR}/*.network ${D}${sysconfdir}/systemd/network
}

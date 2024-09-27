require xen-source.inc

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += " \
    file://xenpcid-xenstore.conf \
"

PACKAGES:append = "\
    ${PN}-pcid \
"

FILES:${PN}-test = "\
    ${libdir}/xen/bin/test-xenstore \
    ${libdir}/xen/bin/test-resource \
"

FILES:${PN}-pcid = "\
    ${systemd_unitdir}/system/xenpcid.service \
    ${systemd_unitdir}/system/xenpcid.service.d/xenpcid-xenstore.conf \
"

# Remove the recommendation for Qemu for non-hvm x86 added in meta-virtualization layer
RRECOMMENDS:${PN}:remove = "qemu"

# Avoid redundant runtime dependency on python3-core
RDEPENDS:${PN}:remove:class-target = "${PYTHON_PN}-core"

DEPENDS:remove = "pixman virtual/libsdl"

SYSTEMD_SERVICE:${PN}-pcid = "xenpcid.service"

SYSTEMD_PACKAGES += "${PN}-pcid"

do_install:append() {
    install -d ${D}${systemd_unitdir}/system/xenpcid.service.d/
    install -m 0744 ${WORKDIR}/xenpcid-xenstore.conf ${D}${systemd_unitdir}/system/xenpcid.service.d
}

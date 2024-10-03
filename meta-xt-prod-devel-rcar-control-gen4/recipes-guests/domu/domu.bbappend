FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

RDEPENDS:${PN} = "backend-ready"
SRC_URI += "\
    file://domu-set-root \
    file://domu.service \
    file://domu-vdevices.cfg \
"

FILES:${PN} += " \
    ${libdir}/xen/bin/domu-set-root \
"

# It is used a lot in the do_install, so variable will be handy
CFG_FILE="${D}${sysconfdir}/xen/domu.cfg"

do_install:append() {

    # HACK: FOR V4H ONLY!
    # Right now we can't append vdevices, because they are absent,
    # also we have isssue with proper work of the domu-set-root,
    # so the only working device (disk) is added directly in
    # the domu-whitehawk.cfg
    # cat ${WORKDIR}/domu-vdevices.cfg >> ${CFG_FILE}

    # Install domu-set-root script
    install -d ${D}${libdir}/xen/bin
    install -m 0744 ${WORKDIR}/domu-set-root ${D}${libdir}/xen/bin

    # Call domu-set-root script
    echo "[Service]" >> ${D}${systemd_unitdir}/system/domu.service
    echo "ExecStartPre=${libdir}/xen/bin/domu-set-root" >> ${D}${systemd_unitdir}/system/domu.service
}

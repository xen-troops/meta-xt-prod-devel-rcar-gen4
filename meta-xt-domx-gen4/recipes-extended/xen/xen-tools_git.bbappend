require xen-4.16-dunfell.inc

PACKAGES_append = "\
    ${PN}-test \
    ${PN}-pcid \
"

FILES_${PN}-test = "\
    ${libdir}/xen/bin/test-xenstore \
    ${libdir}/xen/bin/test-resource \
"

FILES_${PN}-pcid = "\
    ${systemd_unitdir}/system/xenpcid.service \
"

SYSTEMD_SERVICE_${PN}-pcid = "xenpcid.service"


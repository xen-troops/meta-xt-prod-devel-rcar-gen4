require xen-4.16-dunfell.inc

PACKAGES_append = "\
    ${PN}-test \
"

FILES_${PN}-test = "\
    ${libdir}/xen/bin/test-xenstore \
    ${libdir}/xen/bin/test-resource \
"

require optee.inc

EXTRA_OEMAKE += " CFG_NS_VIRTUALIZATION=y CFG_VIRT_GUEST_COUNT=3"

do_install:append() {
    install -m 644 ${B}/core/tee.srec ${D}${nonarch_base_libdir}/firmware/tee-spider.srec
}

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append:spider = " \
    file://early_printk_spider.cfg \
"

do_configure:append() {
    # merge configuration fragments manually using kconfig's native facilities
    ${S}/xen/tools/kconfig/merge_config.sh -m -O ${B}/xen ${B}/xen/.config ${WORKDIR}/*.cfg
}

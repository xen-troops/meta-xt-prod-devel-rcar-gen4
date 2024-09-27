FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append = " \
    file://early_printk.cfg \
    file://0001-iommu-ipmmu-vmsa-Add-Renesas-R8A779G0-R-Car-V4H-supp.patch \
    file://0001-iommu-ipmmu-vmsa-Skip-preinit-for-R8A779G0-as-well.patch \
    file://0001-arm-Change-GUEST_GICV3_ITS_BASE.patch \
    file://0001-pci-Add-support-for-V4H-pcie-host.patch \
"

do_configure:append() {
    # merge configuration fragments manually using kconfig's native facilities
    ${S}/xen/tools/kconfig/merge_config.sh -m -O ${B}/xen ${B}/xen/.config ${WORKDIR}/*.cfg
}

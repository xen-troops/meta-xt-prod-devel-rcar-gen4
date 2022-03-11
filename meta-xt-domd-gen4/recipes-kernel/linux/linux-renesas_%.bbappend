FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

BRANCH = "v5.10.41/rcar-5.1.3.rc11"
SRCREV = "9acb07efa6c070d753ac1de4a146603299e51a49"

SRC_URI_append = "\
    file://defconfig \
"

SRC_URI_append = " \
    file://r8a779f0.cfg \
    file://rswitch.cfg \
    file://dmatest.cfg \
    file://8139.cfg \
    file://xen-chosen.dtsi;subdir=git/arch/arm64/boot/dts/renesas \
    file://0001-clk-shmobile-Hide-clock-for-scif3-and-hscif0.patch \
    file://0001-xen-pciback-allow-compiling-on-other-archs-than-x86.patch \
    file://0002-HACK-Allow-DomD-enumerate-PCI-devices.patch \
    file://0001-WIP-PCIe-MSI-support.patch \
"

ADDITIONAL_DEVICE_TREES = "${XT_DEVICE_TREES}"

# Ignore in-tree defconfig
KBUILD_DEFCONFIG = ""

# Don't build defaul DTBs
KERNEL_DEVICETREE = ""

KERNEL_MODULE_PROBECONF += "8139cp"
module_conf_8139cp = "blacklist 8139cp"

KERNEL_MODULE_PROBECONF += "8139too"
module_conf_8139too = "blacklist 8139too"

# Add ADDITIONAL_DEVICE_TREES to SRC_URIs and to KERNEL_DEVICETREEs
python __anonymous () {
    for fname in (d.getVar("ADDITIONAL_DEVICE_TREES") or "").split():
        dts = fname[:-3] + "dts"
        d.appendVar("SRC_URI", " file://%s;subdir=git/arch/${ARCH}/boot/dts/renesas"%dts)
        dtb = fname[:-3] + "dtb"
        d.appendVar("KERNEL_DEVICETREE", " renesas/%s"%dtb)
}

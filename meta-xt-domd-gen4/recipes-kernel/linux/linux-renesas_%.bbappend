FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

RENESAS_BSP_URL = "git://github.com/xen-troops/linux.git"
BRANCH = "v5.10.41/rcar-5.1.3.rc11-xt"
SRCREV = "dfa13e18e1e4fc3575725d7a0e4432879ff685b1"

SRC_URI_append = "\
    file://defconfig \
"

SRC_URI_append = " \
    file://r8a779f0.cfg \
    file://rswitch.cfg \
    file://dmatest.cfg \
    file://gpio.cfg \
    file://xen-chosen.dtsi;subdir=git/arch/arm64/boot/dts/renesas \
    file://0001-clk-shmobile-Hide-clock-for-scif3-and-hscif0.patch \
    file://0001-xen-pciback-allow-compiling-on-other-archs-than-x86.patch \
    file://0002-HACK-Allow-DomD-enumerate-PCI-devices.patch \
    file://0001-WIP-PCIe-MSI-support.patch \
    file://0001-HACK-pcie-renesas-emulate-reading-from-ECAM-under-Xe.patch \
"

ADDITIONAL_DEVICE_TREES = "${XT_DEVICE_TREES}"

# Ignore in-tree defconfig
KBUILD_DEFCONFIG = ""

# Don't build defaul DTBs
KERNEL_DEVICETREE = ""

# Add ADDITIONAL_DEVICE_TREES to SRC_URIs and to KERNEL_DEVICETREEs
python __anonymous () {
    for fname in (d.getVar("ADDITIONAL_DEVICE_TREES") or "").split():
        dts = fname[:-3] + "dts"
        d.appendVar("SRC_URI", " file://%s;subdir=git/arch/${ARCH}/boot/dts/renesas"%dts)
        dtb = fname[:-3] + "dtb"
        d.appendVar("KERNEL_DEVICETREE", " renesas/%s"%dtb)
}

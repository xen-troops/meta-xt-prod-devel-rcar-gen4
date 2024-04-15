FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

RENESAS_BSP_URL = "git://github.com/xen-troops/linux.git"
BRANCH = "${XT_KERNEL_BRANCH}"
SRCREV = "${XT_KERNEL_REV}"

SRC_URI:append = " \
    file://ixgbe.cfg \
    file://ufs.cfg \
    file://multicast_routing.cfg \
    file://xen-chosen.dtsi;subdir=git/arch/arm64/boot/dts/renesas \
    file://0001-clk-shmobile-Hide-clock-for-scif3-and-hscif0.patch \
    file://0002-PCIe-MSI-support.${MACHINE}.patch \
    file://0003-xen-pciback-allow-compiling-on-other-archs-than-x86.patch \
    file://0004-HACK-Allow-DomD-enumerate-PCI-devices.patch \
    file://0005-HACK-pcie-renesas-emulate-reading-from-ECAM-under-Xe.patch \
    file://r8a779f0-domd.dts;subdir=git/arch/arm64/boot/dts/renesas \
    file://r8a779f0-xen.dts;subdir=git/arch/arm64/boot/dts/renesas \
"

KERNEL_MODULE_PROBECONF += "ixgbevf"
module_conf_ixgbevf = "blacklist ixgbevf"

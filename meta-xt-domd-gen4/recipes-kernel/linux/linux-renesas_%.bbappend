FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

RENESAS_BSP_URL:r8a779f0 = "git://github.com/xen-troops/linux.git"
BRANCH:r8a779f0 = "${XT_KERNEL_BRANCH}"
SRCREV:r8a779f0 = "${XT_KERNEL_REV}"

SRC_URI:append = " \
    file://ixgbe.cfg \
    file://multicast_routing.cfg \
    file://xen-chosen.dtsi;subdir=git/arch/arm64/boot/dts/renesas \
    file://r8a779g0-xen-chosen.dtsi;subdir=git/arch/arm64/boot/dts/renesas \
    file://0001-clk-shmobile-Hide-clock-for-scif3-and-hscif0.patch \
    file://r8a779f0-domd.dts;subdir=git/arch/arm64/boot/dts/renesas \
    file://r8a779f0-xen.dts;subdir=git/arch/arm64/boot/dts/renesas \
    file://r8a779g0-xen.dts;subdir=git/arch/arm64/boot/dts/renesas \
    file://r8a779g0-domd.dts;subdir=git/arch/arm64/boot/dts/renesas \
    file://0001-xen-Initial-version-of-Xen-passthrough-helper-driver.patch \
    file://0002-PCIe-MSI-support.${MACHINE}.patch \
    file://0004-HACK-Allow-DomD-enumerate-PCI-devices.patch \
    file://0003-xen-pciback-allow-compiling-on-other-archs-than-x86.patch \
"

SRC_URI:remove:rcar-v4x = "file://0001-arm64-dts-renesas-r8a779g0-Add-Native-device-support.patch"

SRC_URI:append:r8a779f0 = " \
    file://0005-HACK-pcie-renesas-emulate-reading-from-ECAM-under-Xe.patch \
    file://ufs.cfg \
"
KERNEL_MODULE_PROBECONF += "ixgbevf"
module_conf_ixgbevf = "blacklist ixgbevf"

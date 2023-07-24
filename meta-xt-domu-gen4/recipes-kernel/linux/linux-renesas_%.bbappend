FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

RENESAS_BSP_URL = "git://github.com/xen-troops/linux.git"
BRANCH = "${XT_KERNEL_BRANCH}"
SRCREV = "${XT_KERNEL_REV}"

SRC_URI:append = "\
    file://r8a779f0-spider-domu.dts;subdir=git/arch/${ARCH}/boot/dts/renesas \
    file://rswitch.cfg \
    file://dmatest.cfg \
    file://ixgbevf.cfg \
"

KERNEL_DEVICETREE:append = " renesas/r8a779f0-spider-domu.dtb"

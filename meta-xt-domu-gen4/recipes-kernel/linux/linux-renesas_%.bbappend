FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

RENESAS_BSP_URL = "git://github.com/xen-troops/linux.git"
BRANCH = "v5.10.41/rcar-5.1.6.rc3-xt"
SRCREV = "8a4d83648ad46b9091aef9e17077083ec25ab0d2"

SRC_URI_append = "\
    file://r8a779f0-spider-domu.dts;subdir=git/arch/${ARCH}/boot/dts/renesas \
    file://defconfig \
    file://rswitch.cfg \
    file://dmatest.cfg \
"

KERNEL_DEVICETREE_append = " renesas/r8a779f0-spider-domu.dtb"

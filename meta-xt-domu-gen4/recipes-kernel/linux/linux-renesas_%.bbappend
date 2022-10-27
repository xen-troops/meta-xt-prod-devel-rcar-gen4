FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

RENESAS_BSP_URL = "git://github.com/xen-troops/linux.git"
BRANCH = "v5.10.41/rcar-5.1.7.rc3-xt"
SRCREV = "e74fea0be1d2553617f13344babdfbeb0cee4eeb"

SRC_URI_append = "\
    file://r8a779f0-spider-domu.dts;subdir=git/arch/${ARCH}/boot/dts/renesas \
    file://defconfig \
    file://rswitch.cfg \
    file://dmatest.cfg \
"

KERNEL_DEVICETREE_append = " renesas/r8a779f0-spider-domu.dtb"

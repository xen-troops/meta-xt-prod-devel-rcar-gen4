FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

RENESAS_BSP_URL = "git://github.com/xen-troops/linux.git"
BRANCH = "v5.10.41/rcar-5.1.6.rc3-xt"
SRCREV = "e6b9e652e7e0b1bb7caa8a6a638678afaa8723ea"

SRC_URI_append = "\
    file://r8a779f0-spider-domu.dts;subdir=git/arch/${ARCH}/boot/dts/renesas \
    file://defconfig \
    file://rswitch.cfg \
"

KERNEL_DEVICETREE_append = " renesas/r8a779f0-spider-domu.dtb"

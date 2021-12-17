FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

RENESAS_BSP_URL = "git://github.com/renesas-rcar/linux-bsp.git"

SRC_URI_append = "\
    file://r8a779f0-spider-domu.dts;subdir=git/arch/${ARCH}/boot/dts/renesas \
    file://defconfig \
    file://8139.cfg \
"

KERNEL_DEVICETREE_append = " renesas/r8a779f0-spider-domu.dtb"

KERNEL_MODULE_PROBECONF += "8139cp"
module_conf_8139cp = "blacklist 8139cp"

KERNEL_MODULE_PROBECONF += "8139too"
module_conf_8139too = "blacklist 8139too"

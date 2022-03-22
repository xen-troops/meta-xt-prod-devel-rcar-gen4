FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

RENESAS_BSP_URL = "git://github.com/renesas-rcar/linux-bsp.git"

BRANCH = "v5.10.41/rcar-5.1.3.rc11"
SRCREV = "9acb07efa6c070d753ac1de4a146603299e51a49"

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

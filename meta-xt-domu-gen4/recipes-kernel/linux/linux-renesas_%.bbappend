FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

RENESAS_BSP_URL = "git://github.com/renesas-rcar/linux-bsp.git"

BRANCH = "v5.10.41/rcar-5.1.3.rc5"
SRCREV = "${AUTOREV}"
LINUX_VERSION = "5.10.41"

COMPATIBLE_MACHINE .= "|spider"

SRC_URI_remove = "\
    file://touch.cfg \
    file://add-intc_ex-for-r8a77961.patch \
    file://cpufreq-boost-for-rcar-5.0.0.rc4.patch \
    file://0001-arm64-dts-r8a77961-Fix-video-codec-relation-node.patch \
    file://0001-scripts-Add-module.lds-to-fix-out-of-tree-modules-bu.patch \
    file://0001-arm64-dts-r8a77995-Add-optee-node.patch \
    file://disable_fw_loader_user_helper.cfg \
    file://ulcb-ab.dtsi;subdir=git/arch/arm64/boot/dts/renesas \
"

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

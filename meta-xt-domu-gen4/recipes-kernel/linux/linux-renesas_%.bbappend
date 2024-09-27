FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

RENESAS_BSP_URL:r8a779f0 = "git://github.com/xen-troops/linux.git"
BRANCH:r8a779f0 = "${XT_KERNEL_BRANCH}"
SRCREV:r8a779f0 = "${XT_KERNEL_REV}"

SRC_URI:append = "\
    file://defconfig \
    file://dmatest.cfg \
"

SRC_URI:append:r8a779f0 = "\
    file://r8a779f0-${MACHINE}-domu.dts;subdir=git/arch/${ARCH}/boot/dts/renesas \
    file://rswitch.cfg \
    file://ixgbevf.cfg \
"

SRC_URI:append:r8a779g0 = " \
    file://r8a779g0-${MACHINE}-domu.dts;subdir=git/arch/${ARCH}/boot/dts/renesas \
    file://r8a779g0.cfg \
"

SRC_URI:remove:rcar-v4x = "file://0001-arm64-dts-renesas-r8a779g0-Add-Native-device-support.patch"
KERNEL_DEVICETREE:append:r8a779f0 = " renesas/r8a779f0-${MACHINE}-domu.dtb"
KERNEL_DEVICETREE:append:r8a779g0 = " renesas/r8a779g0-${MACHINE}-domu.dtb"

# Ignore in-tree defconfig
KBUILD_DEFCONFIG = ""

KERNEL_DEVICETREE = "${XT_DOMU_DTB_NAME}"

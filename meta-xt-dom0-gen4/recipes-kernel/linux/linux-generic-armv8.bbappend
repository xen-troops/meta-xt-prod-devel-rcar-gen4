FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

BRANCH = "v5.10.41/rcar-5.1.3.rc5"
SRCREV = "${AUTOREV}"
LINUX_VERSION = "5.10.41"

SRC_URI = "\
    git://github.com/renesas-rcar/linux-bsp.git;branch=${BRANCH} \
    file://defconfig \
    file://0001-xen-pciback-allow-compiling-on-other-archs-than-x86.patch \
"

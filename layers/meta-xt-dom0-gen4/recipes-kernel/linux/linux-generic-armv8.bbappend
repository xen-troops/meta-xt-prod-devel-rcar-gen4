FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

BRANCH = "v5.10.41/rcar-5.1.7.rc5"
SRCREV = "5b26eb114c74c907671d996128bb0233f516703c"
LINUX_VERSION = "5.10.41"

SRC_URI = "\
    git://github.com/renesas-rcar/linux-bsp.git;branch=${BRANCH};protocol=https \
    file://defconfig \
"

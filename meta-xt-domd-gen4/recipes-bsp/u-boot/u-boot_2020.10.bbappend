FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += " \
    file://0001-arm-dts-r8a779f0-Add-Renesas-UFS-HCD-support.patch \
    file://0002-ufs-flush-invalidate-command-buffer.patch \
    file://0003-ufs-port-linux-driver-for-rcar-ufshcd.patch \
    file://0004-clk-renesas-Add-and-enable-CPG-reset-driver-for-Gen4.patch \
    file://0005-ufs-reset-UFS-controller-on-init.patch \
    file://ufs.cfg \
"

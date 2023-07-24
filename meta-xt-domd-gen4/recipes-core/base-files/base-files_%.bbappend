
# meta-renesas does strange things with fstab file to fix own problems
# with NFS. We don't have such problems, so we need to revert some changes
# made by Renesas. Namely, we want /var/volatile to be owned by root.
do_install:append() {
    sed -i "s/uid=65534,gid=65534/defaults/" ${D}${sysconfdir}/fstab
}

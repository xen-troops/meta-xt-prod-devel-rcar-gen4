IMAGE_INSTALL += " \
    pciutils \
    devmem2 \
    iccom-support \
    optee-test \
"

IMAGE_INSTALL += "iproute2 iproute2-tc tcpdump nvme-cli"

IMAGE_INSTALL += " kernel-module-nvme-core kernel-module-nvme"

IMAGE_INSTALL += " kernel-module-ixgbe"

IMAGE_INSTALL += "e2fsprogs"

IMAGE_INSTALL:append = " \
    xen \
    xen-tools-devd \
    xen-tools-scripts-network \
    xen-tools-scripts-block \
    xen-tools-xenstore \
    xen-tools-pcid \
    xen-network \
    dnsmasq \
"

IMAGE_INSTALL += " \
    pciutils \
    devmem2 \
"
IMAGE_INSTALL:append:r8a779f0 = " \
    iccom-support \
    optee-test \
"

IMAGE_INSTALL += "iproute2 iproute2-tc tcpdump nvme-cli"

IMAGE_INSTALL += " kernel-module-nvme-core kernel-module-nvme"

IMAGE_INSTALL += " kernel-module-ixgbe"

IMAGE_INSTALL += "e2fsprogs"

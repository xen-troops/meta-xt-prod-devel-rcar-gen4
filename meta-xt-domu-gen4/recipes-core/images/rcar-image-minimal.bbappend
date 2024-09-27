IMAGE_INSTALL += " \
    pciutils \
    devmem2 \
    vmq-network \
"

IMAGE_INSTALL:append:r8a779f0 = " \
    iccom-support \
    optee-test \
"

IMAGE_INSTALL += "kernel-module-nvme"
IMAGE_INSTALL += "kernel-module-nvme-core"

#IMAGE_INSTALL += "kernel-module-ixgbevf"

IMAGE_INSTALL += "e2fsprogs"
IMAGE_INSTALL += "iproute2 iproute2-tc"

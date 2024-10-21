IMAGE_INSTALL:append = " \
    pciutils \
    devmem2 \
    iccom-support \
    optee-test \
    vmq-network \
"

IMAGE_INSTALL:append = " kernel-module-nvme"
IMAGE_INSTALL:append = " kernel-module-nvme-core"

IMAGE_INSTALL:append = " kernel-module-ixgbevf"

IMAGE_INSTALL:append = " e2fsprogs"
IMAGE_INSTALL:append = " iproute2 iproute2-tc"

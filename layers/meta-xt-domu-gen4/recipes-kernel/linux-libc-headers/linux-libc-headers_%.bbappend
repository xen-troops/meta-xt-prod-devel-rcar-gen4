RENESAS_BSP_URL = "git://github.com/renesas-rcar/linux-bsp.git"

BRANCH = "v5.10.41/rcar-5.1.3.rc5"
SRCREV = "3429c829ce579530e9269f63009c5eae199dbd0a"
LINUX_VERSION = "5.10.41"

# we need to avoid a situation when both linux and linux-libc-headers
# are fetching the same sources simultaneously because this may result in
# the rejection from the github
do_fetch[depends] = "virtual/kernel:do_fetch"

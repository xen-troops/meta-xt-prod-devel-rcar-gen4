FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

BRANCH="v2020.10/rcar-5.1.0_S4.rc5"
SRCREV = "${AUTOREV}"

# The below patch is aready present in the U-boot version for Spider
SRC_URI_remove = "\
    file://0001-ARM-renesas-Scrub-duplicate-memory-nodes-from-DT-on-.patch \
"

SRC_URI_append = "\
    file://0001-ARM-renesas-Port-memory-nodes-scrubbing-for-Gen4.patch \
"

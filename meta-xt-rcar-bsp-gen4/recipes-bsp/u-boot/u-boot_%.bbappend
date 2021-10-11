BRANCH="v2020.10/rcar-5.1.0_S4.rc5"
SRCREV = "${AUTOREV}"

# FIXME: The below patch enables CONFIG_OF_BOARD_SETUP and breaks the build
# This is needs to be fixed
SRC_URI_remove = "\
    file://0001-ARM-renesas-Scrub-duplicate-memory-nodes-from-DT-on-.patch \
"

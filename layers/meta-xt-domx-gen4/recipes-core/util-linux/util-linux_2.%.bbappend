# This is temporary fix required util vendor provides linux 6.1+
# because required API is not present in linux 5.10.
#
# See detailed explanation in the poky's commit
# b5f4d8952a7e3ea22672951db470f87c65bc8821
# "util-linux: Add PACKAGECONFIG option to mitigate rootfs remount error"
PACKAGECONFIG:remove = "libmount-mountfd-support"

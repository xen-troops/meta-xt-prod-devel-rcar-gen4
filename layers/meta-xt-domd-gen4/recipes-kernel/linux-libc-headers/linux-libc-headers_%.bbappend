# we need to avoid a situation when both linux and linux-libc-headers
# are fetching the same sources simultaneously because this may result in
# the rejection from the github
do_fetch[depends] = "virtual/kernel:do_fetch"

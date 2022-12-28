# meta-xt-rcar-gen4 #

This repository contains Renesas R-Car Gen4-specific Yocto layers for
Xen Troops distro. Some layers in this repository are product-independent.
They provide common facilities that may be used by any xt-based product
that runs on Renesas Gen4-based platforms.

Those layers *may* be added and used manually, but they were written
with [Moulin](https://moulin.readthedocs.io/en/latest/) build system,
as Moulin-based project files provide correct entries in local.conf

# Status

This is a demo setup with offloaded IPS/IDS based on 0.8.8 release of the Xen-based
development product for the S4 Spider board.
# External dependencies

At least IPL 0.5.0 is required for normal operation. Release was
tested with IPL 3.6.0. User is required to flash ARM TF
(bl31-spider.srec) and OP-TEE (tee-spider.srec) provided by the build
to ensure that Xen and DomD/DomU will work correctly.

# Documentation

- [Building][]
- [Virtualization][]
- [TC and L3 offload][]
- [IPD/IDS][]

[Building]: ./doc/building.md
[Virtualization]: ./doc/virtualization.md
[TC and L3 offload]: ./doc/tc-and-l3-offload.md
[IPD/IDS]: ./doc/ips-ids.md

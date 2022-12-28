# meta-xt-rcar-gen4 #

This repository contains Renesas R-Car Gen4-specific Yocto layers for
Xen Troops distro. Some layers in this repository are product-independent.
They provide common facilities that may be used by any xt-based product
that runs on Renesas Gen4-based platforms.

Those layers *may* be added and used manually, but they were written
with [Moulin](https://moulin.readthedocs.io/en/latest/) build system,
as Moulin-based project files provide correct entries in local.conf

# Status

This is a release 0.8.9 of the Xen-based development product for the
S4 Spider board.

This release provides the following features:

 - Xen build compatible with S4 SoC
 - Thin Dom0
 - Driver domain (DomD), which has access to all available hardware
 - Optional generic domain (DomU)
 - Support for OP-TEE in virtualization mode
 - ICCOM partitioning demo (proprietary components are required to
   test the feature)
 - R-Switch VMQ: R-Switch virtualization feature
 - R-Switch VMQ TSN: R-Switch TSN pass-through feature
 - R-Switch L3 routing offload (including VLAN routes)
 - R-Switch traffic control offload
 - R-Switch offloaded IPS/IDS Snort support
 - Disabling L3 HW forwarding respectively to /proc/sys/net/ipv4/ip_forward value
 - Virtualized OP-TEE support
 - PCIe SR-IOV support

The following HW modules were tested and are confirmed to work:

 - Serial console (HSCIF)
 - IPMMUs
 - R-Switch
 - eMMC
 - PCIe with ITS (but there is a running issue with MSI interrupts
   that sometimes do not work)

# External dependencies

At least IPL 0.5.0 is required for normal operation. Release was
tested with IPL 3.6.0. User is required to flash ARM TF
(bl31-spider.srec) and OP-TEE (tee-spider.srec) provided by the build
to ensure that Xen and DomD/DomU will work correctly.

# Documentation

- [Building][]
- [Virtualization][]
- [TC and L3 offload][]

[Building]: ./doc/building.md
[Virtualization]: ./doc/virtualization.md
[TC and L3 offload]: ./doc/tc-and-l3-offload.md

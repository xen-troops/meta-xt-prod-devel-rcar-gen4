# meta-xt-rcar-gen4 #

This repository contains Renesas R-Car Gen4-specific Yocto layers for
Xen Troops distro. Some layers in this repository are product-independent.
They provide common facilities that may be used by any xt-based product
that runs on Renesas Gen4-based platforms.

Those layers *may* be added and used manually, but they were written
with [Moulin](https://moulin.readthedocs.io/en/latest/) build system,
as Moulin-based project files provide correct entries in local.conf

# Status

This is an alpha release of the Xen-based development product for the
S4 Spider board.

This release provides the following features:

 - Xen build compatible with S4 SoC
 - Thin Dom0
 - Driver domain (DomD), which has access to all available hardware
 - Optional generic domain (DomU)

The following HW modules were tested and are confirmed to work:

 - Serial console (SCIF)
 - IPMMUs
 - R-Switch (tsn0 interface only)
 - eMMC

Known issues:
 - R-Switch is sometimes unreliable during initialization phase,
   so sometimes the board reboot is required for DomD to come up.
 - Only 2GiB are used.
 - Multi-core is not supported yet. Only one CortexA core is enabled.
 - ARM Trusted Firmware is not integrated into this release.

# Building
## Requirements

1. Ubuntu 18.0+ or any other Linux distribution which is supported by Poky/OE
2. Development packages for Yocto. Refer to [Yocto
   manual](https://www.yoctoproject.org/docs/current/mega-manual/mega-manual.html#brief-build-system-packages).
3. You need `Moulin` installed in your PC. Recommended way is to
   install it for your user only: `pip3 install --user
   git+https://github.com/xen-troops/moulin`. Make sure that your
   `PATH` environment variable includes `${HOME}/.local/bin`.
4. Ninja build system: `sudo apt install ninja-build` on Ubuntu

## Fetching

You can fetch/clone this whole repository, but you actually only need
one file from it: `prod-devel-rcar-s4.yaml`. During the build `moulin`
will fetch this repository again into `yocto/` directory. So, to
reduce possible confuse, we recommend to download only
`prod-devel-rcar-s4.yaml`:

```
# curl -O https://raw.githubusercontent.com/xen-troops/meta-xt-prod-devel-rcar-gen4/spider-alpha/prod-devel-rcar-s4.yaml
```

## Building

Moulin is used to generate Ninja build file: `moulin
prod-devel-rcar-s4.yaml`. This project provides number of additional
parameters. You can check them with `--help-config` command
line option:

```
# moulin prod-devel-rcar-s4.yaml --help-config
usage: moulin prod-devel-rcar-s4.yaml
       [--MACHINE {spider}] [--ENABLE_DOMU {no,yes}]

Config file description: Xen-Troops development setup for Renesas RCAR Gen4
hardware

optional arguments:
  --MACHINE {spider}    RCAR Gen4-based device
  --ENABLE_DOMU {no,yes}
                        Build generic Yocto-based DomU
```

Only one machine is supported as of now: `spider`. You can enable or
disable DomU build with `--ENABLE_DOMU=yes` option.
Be default it is disabled.

So, to build with DomU (generic Yocto-based virtual machine) use the
following command line: `moulin prod-devel-rcar-s4.yaml
--ENABLE_DOMU=yes`.

Moulin will generate `build.ninja` file. After that run `ninja` to
build the images. This will take some time and disk space as it builds
3 separate Yocto images.

## Creating SD card image

Image file can be created with `rouge` tool. This is a companion
application for `moulin`.

Right now it works only in standalone mode, so manual invocation is
required. It accepts the same parameters: `--MACHINE`,
`--ENABLE_DOMU`.

This XT product provides only one image: `full`.

You can prepare the image by running

```
# rouge prod-devel-rcar-s4.yaml --ENABLE_DOMU=yes -i full
```

This will create file `full.img` in your current directory.

Also you can write image directly to an SD card by running

```
# sudo rouge prod-devel-rcar.yaml --ENABLE_DOMU=yes -i full -so /dev/sdX
```

**BE SURE TO PROVIDE CORRECT DEVICE NAME**. `rouge` has no
interactive prompts and will overwrite your device right away. **ALL
DATA WILL BE LOST**.

It is also possible to flash the image to the internal eMMC.
For that you may want booting the board via TFTP and sharing DomD's
root file system via NFS. Once booted it is possible to flash the image:

```
# dd=/full.img of=/dev/mmcblk0 bs=1M
```

For more information about `rouge` check its
[manual](https://moulin.readthedocs.io/en/latest/rouge.html).

## U-boot environment

Please make sure 'bootargs' variable is unset while running with Xen:
```
unset bootargs
```

It is possible to run the build from TFTP+NFS and eMMC.
Please set the following environment for that:

```
setenv bootcmd 'run bootcmd_tftp'
setenv bootcmd_mmc0 'run mmc0_xen_load; run mmc0_dtb_load; run mmc0_kernel_load; run mmc0_xenpolicy_load; run mmc0_initramfs_load; bootm 0x48080000 0x84000000 0x48000000'
setenv bootcmd_tftp 'run tftp_xen_load; run tftp_dtb_load; run tftp_kernel_load; run tftp_xenpolicy_load; run tftp_initramfs_load; bootm 0x48080000 0x84000000 0x48000000'

setenv mmc0_dtb_load 'ext2load mmc 0:1 0x48000000 xen.dtb; fdt addr 0x48000000; fdt resize; fdt mknode / boot_dev; fdt set /boot_dev device mmcblk0'
setenv mmc0_initramfs_load 'ext2load mmc 0:1 0x84000000 uInitramfs'
setenv mmc0_kernel_load 'ext2load mmc 0:1 0x7a000000 Image'
setenv mmc0_xen_load 'ext2load mmc 0:1 0x48080000 xen'
setenv mmc0_xenpolicy_load 'ext2load mmc 0:1 0x7c000000 xenpolicy'

setenv tftp_dtb_load 'tftp 0x48000000 r8a779f0-spider-xen.dtb; fdt addr 0x48000000; fdt resize; fdt mknode / boot_dev; fdt set /boot_dev device nfs'
setenv tftp_initramfs_load 'tftp 0x84000000 uInitramfs'
setenv tftp_kernel_load 'tftp 0x7a000000 Image'
setenv tftp_xen_load 'tftp 0x48080000 xen-uImage'
setenv tftp_xenpolicy_load 'tftp 0x7c000000 xenpolicy-spider'

```

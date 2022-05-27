# meta-xt-rcar-gen4 #

This repository contains Renesas R-Car Gen4-specific Yocto layers for
Xen Troops distro. Some layers in this repository are product-independent.
They provide common facilities that may be used by any xt-based product
that runs on Renesas Gen4-based platforms.

Those layers *may* be added and used manually, but they were written
with [Moulin](https://moulin.readthedocs.io/en/latest/) build system,
as Moulin-based project files provide correct entries in local.conf

# Status

This is a release 0.8.1 of the Xen-based development product for the
S4 Spider board.

This release provides the following features:

 - Xen build compatible with S4 SoC
 - Thin Dom0
 - Driver domain (DomD), which has access to all available hardware
 - Optional generic domain (DomU)
 - Support for OP-TEE in virtualization mode
 - ICCOM partitioning demo (proprietary components are required to
   test the feature)
 - R-Switch VMQ (R-Switch virtualization feature)
 - Virtualized OP-TEE support
 - PCIe SR-IOV support

The following HW modules were tested and are confirmed to work:

 - Serial console (HSCIF)
 - IPMMUs
 - R-Switch (tsn0 interface only)
 - eMMC
 - PCIe with ITS

# External dependencies

At least IPL 0.5.0 is required for normal operation. Release was
tested with IPL 0.7.0. User is required to flash ARM TF
(bl31-spider.srec) and OP-TEE (tee-spider.srec) provided by the build
to ensure that Xen and DomD/DomU will work correctly.

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
# curl -O https://raw.githubusercontent.com/xen-troops/meta-xt-prod-devel-rcar-gen4/spider-0.8.1/prod-devel-rcar-s4.yaml
```

## Building

Moulin is used to generate Ninja build file: `moulin
prod-devel-rcar-s4.yaml`. This project provides number of additional
parameters. You can check them with `--help-config` command
line option:

```
# moulin prod-devel-rcar-s4.yaml --help-config
usage: moulin prod-devel-rcar-s4.yaml [--ENABLE_DOMU {no,yes}]

Config file description: Xen-Troops development setup for Renesas RCAR Gen4
hardware

optional arguments:
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

### Using Ninja

Latest versions of `moulin` will generate additional ninja targets for
creating images. In case of this product please use

```
# ninja image-full
```

To generate SD/eMMC image `full.img`. You can use `dd` tool to write
this image file to a SD card:

```
# dd if=full.img of=/dev/sdX conv=sparse
```

If you want to write image directly to a SD card (e.g. without
creating `full.img` file), you will need to use manual mode, which is
described in the next subsection.

### Manually, using `rouge`

Image file can be created with `rouge` tool. This is a companion
application for `moulin`.

Right now it works only in standalone mode, so manual invocation is
required. It accepts the same parameters: `--ENABLE_DOMU`.

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
# dd if=/full.img of=/dev/mmcblk0 bs=1M
```

For more information about `rouge` check its
[manual](https://moulin.readthedocs.io/en/latest/rouge.html).

## U-boot environment

Please make sure 'bootargs' variable is unset while running with Xen:
```
unset bootargs
```

It is possible to run the build from TFTP+NFS and eMMC. With NFS boot
is is possible to configure board IP, server IP and NFS path for DomD
and DomU. Please set the following environment for that:

```
setenv set_pcie 'i2c dev 0; i2c mw 0x6c 0x26 5; i2c mw 0x6c 0x254.2 0x1e; i2c mw 0x6c 0x258.2 0x1e; i2c mw 0x20 0x3.1 0xfe;'

setenv bootcmd 'run set_pcie; run bootcmd_tftp'
setenv bootcmd_mmc0 'run mmc0_xen_load; run mmc0_dtb_load; run mmc0_kernel_load; run mmc0_xenpolicy_load; run mmc0_initramfs_load; bootm 0x48080000 0x84000000 0x48000000'
setenv bootcmd_tftp 'run tftp_xen_load; run tftp_dtb_load; run tftp_kernel_load; run tftp_xenpolicy_load; run tftp_initramfs_load; bootm 0x48080000 0x84000000 0x48000000'

setenv mmc0_dtb_load 'ext2load mmc 0:1 0x48000000 xen.dtb; fdt addr 0x48000000; fdt resize; fdt mknode / boot_dev; fdt set /boot_dev device mmcblk0'
setenv mmc0_initramfs_load 'ext2load mmc 0:1 0x84000000 uInitramfs'
setenv mmc0_kernel_load 'ext2load mmc 0:1 0x7a000000 Image'
setenv mmc0_xen_load 'ext2load mmc 0:1 0x48080000 xen'
setenv mmc0_xenpolicy_load 'ext2load mmc 0:1 0x7c000000 xenpolicy'

setenv tftp_configure_nfs 'fdt set /boot_dev device nfs; fdt set /boot_dev my_ip 192.168.1.2; fdt set /boot_dev nfs_server_ip 192.168.1.100; fdt set /boot_dev nfs_dir "/srv/domd"; fdt set /boot_dev domu_nfs_dir "/srv/domu"'
setenv tftp_dtb_load 'tftp 0x48000000 r8a779f0-spider-xen.dtb; fdt addr 0x48000000; fdt resize; fdt mknode / boot_dev; run tftp_configure_nfs; '
setenv tftp_initramfs_load 'tftp 0x84000000 uInitramfs'
setenv tftp_kernel_load 'tftp 0x7a000000 Image'
setenv tftp_xen_load 'tftp 0x48080000 xen-uImage'
setenv tftp_xenpolicy_load 'tftp 0x7c000000 xenpolicy-spider'

```

## NVME configuration for SR-IOV

### One-time NVME configuration

**WARNING! The following commands will destroy all data on your NVME
drive.**

All the following commands should be ran **one time** for each SSD. They
should be performed in DomD.

To enable SR-IOV feature on Samsung SSD we need to create additional
NVME namespaces and attach one of them to a secondary controller. But
first we need to remove default namespace. Be sure to backup any data.

```
root@spider-domd:~# nvme delete-ns /dev/nvme0 -n1
```

Now we need to create at least two namespaces. In this example, they will be
totally identical in sizes (512MB) and features (no special features):

```
root@spider-domd:~# nvme create-ns /dev/nvme0 -s 1048576 -c 1048576 -d0 -m0 -f0
create-ns: Success, created nsid:1
root@spider-domd:~# nvme create-ns /dev/nvme0 -s 1048576 -c 1048576 -d0 -m0 -f0
create-ns: Success, created nsid:2
```

You can list all namespaces:

```
root@spider-domd:~# nvme list-ns /dev/nvme0 -a
[   0]:0x1
[   1]:0x2
```

At this point you might need to reboot board.

Next you'll need to attach first namespace to a primary controller
(that will reside in DomD):

```
root@spider-domd:~# nvme attach-ns /dev/nvme0 -n1 -c0x41
[   47.419062] nvme nvme0: rescanning namespaces.
attach-ns: Success, nsid:1
```

At this point you might need to reboot board again.

And attach second namespace to one of the secondary controllers:

```
root@spider-domd:~# nvme attach-ns /dev/nvme0 -n2 -c0x1
attach-ns: Success, nsid:2
```

This completes one-time setup of SSD.


### Configuring SR-IOV feature of SSD before attaching it to a DomU

Each time you want to attach virtual function to a DomU, you need to
configure SSD resources and enable SR-IOV. Execute the following commands:

```
# nvme virt-mgmt /dev/nvme0 -c 0x1 -r0 -n2 -a8
# nvme virt-mgmt /dev/nvme0 -c 0x1 -r1 -n2 -a8
# echo 1 > /sys/bus/pci/devices/0000\:01\:00.0/sriov_numvfs
# nvme virt-mgmt /dev/nvme0 -c 0x1 -a9
```

After this you can check that secondary NVME controller is online:

```
root@spider-domd:~# nvme list-secondary /dev/nvme0 -e1
Identify Secondary Controller List:
   NUMID       : Number of Identifiers           : 32
   SCEntry[0  ]:
................
     SCID      : Secondary Controller Identifier : 0x0001
     PCID      : Primary Controller Identifier   : 0x0041
     SCS       : Secondary Controller State      : 0x0001 (Online)
     VFN       : Virtual Function Number         : 0x0001
     NVQ       : Num VQ Flex Resources Assigned  : 0x0002
     NVI       : Num VI Flex Resources Assigned  : 0x0002
```

Virtual function will fail to init in DomD:

```
[  317.416769] nvme nvme1: Device not ready; aborting initialisation, CSTS=0x0
[  317.416835] nvme nvme1: Removing after probe failure status: -19
```

This is expected, because secondary controller is being enabled after kernel
tries to access the new PCI device.

`lspci` should display two NVME devices:

```
root@spider-domd:~# lspci
00:00.0 PCI bridge: Renesas Technology Corp. Device 0031
01:00.0 Non-Volatile memory controller: Samsung Electronics Co Ltd Device a824
01:00.2 Non-Volatile memory controller: Samsung Electronics Co Ltd Device a824
```

Now you can uncomment PCI configuration entries in `/etc/xen/domu.cfg`:

```
vpci="ecam"
pci=["01:00.2,seize=1"]
```

Please note that were we share second device (`01:00.2`) while first one stays in DomD.

Restart DomU. You should see a new `/dev/nvme0n1` device in DomU. This
is the second namespace attached to a secondary controller of device
that resides in DomD.

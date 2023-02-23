# Building
## Requirements

1. Ubuntu 18.0+ or any other Linux distribution which is supported by Poky/OE
2. Development packages for Yocto. Refer to [Yocto
   manual](https://docs.yoctoproject.org/brief-yoctoprojectqs/index.html#build-host-packages).
3. You need `Moulin` of version 0.11 or newer installed in your
   PC. Recommended way is to install it for your user only: `pip3
   install --user git+https://github.com/xen-troops/moulin`. Make sure
   that your `PATH` environment variable includes
   `${HOME}/.local/bin`.
4. Ninja build system: `sudo apt install ninja-build` on Ubuntu

## Fetching

You can fetch/clone this whole repository, but you actually only need
one file from it: `prod-devel-rcar-s4.yaml`. During the build `moulin`
will fetch this repository again into `yocto/` directory. So, to
reduce possible confuse, we recommend to download only
`prod-devel-rcar-s4.yaml`:

```
# curl -O https://raw.githubusercontent.com/xen-troops/meta-xt-prod-devel-rcar-gen4/spider-1.0/prod-devel-rcar-s4.yaml
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

## Packing boot artifacts

It is possible to create `.tar.bz` archive with all artifacts that are
required to boot the system. This does not includes DomD and DomU
root file systems. Files that are included:

* Dom0 kernel image (`Image`)
* Dom0 rootfs image (`uInitramfs`)
* Xen hypervisor image (`xen-spider.uImage`)
* Xen policy (`xenpolicy-spider`)
* Device tree (`r8a779f0-spider-xen.dtb`)
* ARM TF BL31 (`bl31-spider.srec`)
* OP-TEE (`tee-spider.srec`)

To build this archive, you can use target `boot_artifacts` for Ninja:

```
# ninja boot_artifacts
```

Archive can be found in `artifacts` folder.

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

### <a name="writing_emmc"></a>Manually, using `rouge`

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

### Booting from eMMC using boot script

First, you need to write generated `full.img` into eMMC. You can't do
this if you are booting via eMMC, so to write `full.img` you need to
boot TFTP/NFS first. Please see the next section on how to do
this. How to write `full.img` to eMMC is described in the end of [this
section](#writing_emmc).

Generated eMMC image contains the boot script for U-Boot, so to boot
via eMMC all you need is to set the following variable:

```
setenv bootcmd 'ext2load mmc 0:1 0x83000000 boot-emmc.uImage; source 0x83000000'
```

### Booting via TFTP/NFS using boot script

TFTP/NFS is done via `boot-tftp.uImage` boot script that can be found
in DomD deploy directory. Put this file into your TFTP server
directory and configure the following variables:

```
editenv ipaddr # Set your board IP address there
editenv serveraddr # Set your boot server IP address there
editenv nfs_domd_dir # (Optinal) Set NFS root directory for DomD
editenv nfs_domu_dir # (Optinal) Set NFS root directory for DomU
setenv bootcmd 'tftp 0x83000000 boot-tftp.uImage; source 0x83000000;'
```

### Manual way of booting via hand-written commands

This is an older approach which provides more flexibility (especially
when booting via network), but requires more actions.

It is possible to run the build from TFTP+NFS and eMMC. With NFS boot
is is possible to configure board IP, server IP and NFS path for DomD
and DomU. Please set the following environment for that:

```
setenv set_pcie 'i2c dev 0; i2c mw 0x6c 0x26 5; i2c mw 0x6c 0x254.2 0x1e; i2c mw 0x6c 0x258.2 0x1e; i2c mw 0x20 0x3.1 0xfe;'

setenv set_ufs 'i2c dev 0; i2c mw 0x6c 0x26 0x05 ;i2c olen 0x6c 2; i2c mw 0x6c 0x13a 0x86 ;i2c mw 0x6c 0x268 0x06; i2c mw 0x6c 0x269 0x00; i2c mw 0x6c 0x26a 0x3c; i2c mw 0x6c 0x26b 0x00; i2c mw 0x6c 0x26c 0x06; i2c mw 0x6c 0x26d 0x00; i2c mw 0x6c 0x26e 0x3f; i2c mw 0x6c 0x26f 0x00'

setenv bootcmd 'run set_pcie; run set_ufs; run bootcmd_tftp'
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

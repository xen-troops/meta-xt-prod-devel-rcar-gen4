# meta-xt-rcar-gen4

This repository contains Renesas R-Car Gen4-specific Yocto layer for support R-Switch L3 HW offload and traffic control offload features.
More information about [L3 Routing offload](https://www.kernel.org/doc/html/latest/networking/switchdev.html#l3-routing-offload) and [traffic control](https://tldp.org/HOWTO/Traffic-Control-HOWTO/) you can find by this links.


Those layers *may* be added and used manually, but they were written
with [Moulin](https://moulin.readthedocs.io/en/latest/) build system,
as Moulin-based project files provide correct entries in local.conf

# Status

This is a release 0.8.4-l3-offload of the L3 development product for the S4 Spider board.

This release provides L3 routing offload feature for IPv4 based on S4 R-Switch MFWD. The feature adds hardware configuration to MFWD via FIB notifier in order to offload CPU and use MFWD mechanisms for routing.

Also, release contains partial support of traffic control filters HW offload. Now it is implemented for all TC filters - matchall, u32 and flower. The list of supported actions: drop and mirred redirect (dst MAC change for u32 is performed by skbmod, but for matchall and flower - by pedit). For u32 and flower filters matching by all key parameters is supported (exc. IPv6): src/dst MACs, IPv4 addrs, L4 ports, IP keys (ToS, TTL), basic keys (EtherType, Net proto). Matchall filter selects all frames by design.

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
# curl -O https://raw.githubusercontent.com/xen-troops/meta-xt-prod-devel-rcar-gen4/spider-0.8.4-l3-offload/prod-devel-rcar-s4.yaml
```

## Building

Moulin is used to generate Ninja build file: `moulin
prod-devel-rcar-s4.yaml`.

## Creating SD card image

### Using Ninja

Latest versions of moulin will generate additional ninja targets for creating images. In case of this product please use

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
required.

This XT product provides only one image: `full`.

You can prepare the image by running

```
# rouge prod-devel-rcar-s4.yaml -i full
```

This will create file `full.img` in your current directory.

Also you can write image directly to an SD card by running

```
# sudo rouge prod-devel-rcar.yaml -i full -so /dev/sdX
```

**BE SURE TO PROVIDE CORRECT DEVICE NAME**. `rouge` has no
interactive prompts and will overwrite your device right away. **ALL
DATA WILL BE LOST**.

It is also possible to flash the image to the internal eMMC.
For that you may want booting the board via TFTP and sharing system's
root file system via NFS. Once booted it is possible to flash the image:

```
# dd if=/full.img of=/dev/mmcblk0 bs=1M
```

For more information about `rouge` check its
[manual](https://moulin.readthedocs.io/en/latest/rouge.html).

## U-boot environment

It is possible to run the build from TFTP+NFS or eMMC. With NFS boot
it is possible to configure board IP, server IP and NFS path for system.
Please set the following environment for that:

```
setenv ipaddr '192.168.1.1'
setenv serverip '192.168.1.100'
setenv tftp_kernel_rswitch_load 'tftp 0x7a000000 Image'
setenv tftp_dtb_rswitch_load 'tftp 0x48000000 r8a779f0-spider.dtb'
setenv bootargs_rswitch 'root=/dev/nfs nfsroot=192.168.1.100:/srv/spider-rswitch,vers=3 ip=192.168.1.1:192.168.1.100::255.255.255.0:board:tsn0::::'
setenv bootcmd_rswitch 'setenv bootargs $bootargs_rswitch; run tftp_dtb_rswitch_load; run tftp_kernel_rswitch_load; booti 0x7a000000 - 0x48000000'
setenv bootcmd='run bootcmd_rswitch'
```

## Testing setup

The setup can be tested using 2 PC or on the same PC. In case of the same PC, the interface connected to TSN2 should be moved to custom network namespace. Also virtual interface in this namespace will be needed.

## Host requirements

- Install `iperf3` package: `sudo apt install iperf3`

## On board:

```
ifconfig tsn2 up 192.168.3.1
echo 1 > /proc/sys/net/ipv4/ip_forward
```

## On host:

### The same PC

```
sudo ip netns add linuxhint
```

#### Interface, connected to tsn2
```
sudo ip link set enp1s0 down
sudo ip link set enp1s0 netns linuxhint
sudo ip netns exec linuxhint ifconfig enp1s0 up
sudo ip netns exec linuxhint ip netns exec linuxhint ifconfig enp1s0 192.168.3.100
sudo ip netns exec linuxhint ip link add virt0 type dummy
sudo ip netns exec linuxhint ifconfig virt0 hw ether C8:D7:4A:4E:47:50 # this can be any valid addr
sudo ip netns exec linuxhint ifconfig virt0 192.168.5.100
sudo ip route add 192.168.3.0/24 via 192.168.1.1
sudo ip route add 192.168.5.0/24 via 192.168.1.1
```

### 2 PC

On main host, connected to TSN0:
```
sudo ip route add 192.168.3.0/24 via 192.168.1.1
sudo ip route add 192.168.5.0/24 via 192.168.1.1
```

#### On host connected to TSN2:
```
sudo ifconfig enp1s0 192.168.3.100
sudo ip link add virt0 type dummy
sudo ifconfig virt0 hw ether C8:D7:4A:4E:47:50
sudo ifconfig virt0 192.168.5.100
```
## Test procedure

### L3 offload
Ping interface connected to TSN2 from host or namespace connected to TSN0:
```
ping 192.168.3.100 -c 10
```

Ensure, that HW routing is used via checking counters on R-Switch interfaces or using `tcpdump` tool.
Routes offloaded to the device are labeled with `offload` in the ip route listing:

```
# ip route show
192.168.1.0/24 dev tsn0 proto kernel scope link src 192.168.1.1 offload
192.168.3.0/24 dev tsn2 proto kernel scope link src 192.168.3.1 offload
```

### Traffic control

To add filter rules for inbound packets you need to create ingress qdisc for test interfaces on board:

```
tc qdisc add dev tsn0 ingress
tc qdisc add dev tsn2 ingress
```

After this you can add filters for these qdiscs. Here are some test cases.

#### u32 filter

To perform drop actions with u32 filter offloaded rule specify it for device as follows:

```
tc filter add dev tsn2 protocol ip parent ffff: u32 match ip src 192.168.3.0/24 skip_sw action drop
```
Following rule will drop all packets from 192.168.3.0/24 subnet, that will come to tsn2 interface. It will lead to ICMP reply packets drop, when you will try to ping 192.168.3.100 from first PC (or without namespace on same PC).

To remove the rule from tc you need to find it pref value with following command:
```
root@spider:~# tc filter show dev tsn2 ingress
filter parent ffff: protocol ip pref 49152 u32 chain 0
filter parent ffff: protocol ip pref 49152 u32 chain 0 fh 800: ht divisor 1
filter parent ffff: protocol ip pref 49152 u32 chain 0 fh 800::800 order 2048 key ht 800 bkt 0 terminal flowid ??? skip_sw in_hw
  match c0a80300/ffffff00 at 12
        action order 1: gact action drop
         random type none pass val 0
         index 1 ref 1 bind 1
```

And now you can remove the following rule by pref (49152)

```
tc filter del dev tsn2 ingress pref 49152
```

Now the list will be empty:
```
root@spider:~# tc filter show dev tsn2 ingress
root@spider:~#
```

Also you can perform setup of redirect action with mirroring. It can be done with following commands (dst mac fields should be set to coresponding addresses of connected to tsnX host ports):
```
tc filter add dev tsn0 protocol ip parent ffff: u32 match ip dst 192.168.5.0/24 skip_sw action skbmod set dmac 48:65:ee:1c:dd:b1 action mirred egress redirect dev tsn2
tc filter add dev tsn2 protocol ip parent ffff: u32 match ip dst 192.168.1.0/24 skip_sw action skbmod set dmac 34:d0:b8:c1:ca:2b action mirred egress redirect dev tsn0
```

This will setup two-way mirroring between tsn0 and tsn2 for specified IPv4 subnets. Now you can try to run ping to virtual interface with 192.168.5.100 address from default namespace (or PC#1 with 2PCs setup) and it will work:
```
ping 192.168.5.100
```
The removal process is the same as for drop action.

#### flower filter

To setup flower filter the workflow is pretty similar as for u32 filter. Three actions for flower filter are supported: drop, mirred redirect and mirred redirect with dst MAC mangling (with pedit). Filter building prototypes you can find in [tc-flower man page](https://man7.org/linux/man-pages/man8/tc-flower.8.html).

Filter examples:
```
tc filter add dev tsn2 protocol ip parent ffff: flower skip_sw dst_ip 192.168.3.0/24 action drop
tc filter add dev tsn0 protocol ip parent ffff: flower dst_ip 192.168.5.0/24 skip_sw action pedit ex munge eth dst set 48:65:ee:1c:dd:b1 pipe action mirred egress redirect dev tsn2
tc filter add dev tsn2 protocol ip parent ffff: flower dst_ip 192.168.1.0/24 skip_sw action pedit ex munge eth dst set 34:d0:b8:c1:ca:2b pipe action mirred egress redirect dev tsn0
tc filter add dev tsn2 protocol ip parent ffff: flower skip_sw ip_ttl 64 action drop
tc filter add dev tsn2 protocol ip parent ffff: flower skip_sw ip_tos 52 action drop
```

The removal process is the same as for u32 filter.


#### matchall

By design matchall filter selects all packets, that are available on dedicated qdisc. The set of supported actions is the same with flower filter.

Example for drop action with matchall:
```
tc filter add dev tsn2 protocol ip parent ffff: matchall skip_sw action drop
```

Mirred redirect:
```
tc filter add dev tsn2 protocol ip parent ffff: matchall skip_sw action pedit ex munge eth dst set 34:d0:b8:c1:ca:2b pipe action mirred egress redirect dev tsn0
```

The removal process is the same as for u32 filter.

#### How to generate traffic for testing filter matching

To generate traffic for testing (e.g. with specific ToS key) you can use `iperf3` tool.
Command examples:
For server
```
iperf3 -s -p 4000 -i 2 #server with 2s interval port 4000
```

For client side:
```
iperf3 -c 192.168.1.100 -p 4000 -t 10 --tos 52
```
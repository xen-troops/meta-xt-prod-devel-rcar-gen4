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

This is expected, because secondary controller is being enabled after
kernel tries to access the new PCI device. You can force reattach it
back. Wait for the mentioned error message and then issue the
following command:

```
root@spider-domd:~# echo 0000:01:00.2 > /sys/bus/pci/drivers/nvme/bind

[ 1165.652567] nvme nvme1: pci function 0000:01:00.2
[ 1165.737307] nvme nvme1: Shutdown timeout set to 10 seconds
[ 1165.771506] nvme nvme1: 1/0/0 default/read/poll queues
```

After that, second device `/dev/nvme1n2` will be present in DomD. This
is a NVMe namespace that will become visible to DomU after we'll enable
PCI device pass-through in the next steps.

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

### Known issues

There are known issue with NVMe interrupts. After virtual function is
enabled, the system stops receiving interrupts for physical
function. From user perspective this looks like DomD have troubles
accessing /dev/nvme0n1.

## Ethernet controller configuration for SR-IOV

### Configuring SR-IOV feature of Ethernet controller before attaching it to a DomU

`lspci` should display two Ethernet devices:

```
root@spider-domd:~# lspci
00:00.0 PCI bridge: Renesas Technology Corp. Device 0031
01:00.0 Ethernet controller: Intel Corporation Ethernet Controller 10G X550T (rev 01)
01:00.1 Ethernet controller: Intel Corporation Ethernet Controller 10G X550T (rev 01)
```

Bring up controller 01:00.0:

```
ip addr add 172.16.15.1/24 dev enp1s0f0
ip link set dev enp1s0f0 up
```

Each time you want to attach virtual function to a DomU, you need to
configure Ethernet controller resources and enable SR-IOV.
Execute the following command:

```
# echo 1 > /sys/bus/pci/devices/0000:01:00.0/sriov_numvfs
```

`lspci` should display three Ethernet devices (two physical functions and
one virtual function):

```
root@spider-domd:~# lspci
00:00.0 PCI bridge: Renesas Technology Corp. Device 0031
01:00.0 Ethernet controller: Intel Corporation Ethernet Controller 10G X550T (rev 01)
01:00.1 Ethernet controller: Intel Corporation Ethernet Controller 10G X550T (rev 01)
02:10.0 Ethernet controller: Intel Corporation X550 Virtual Function
```

Now you can uncomment PCI configuration entries in `/etc/xen/domu.cfg`:

```
vpci="ecam"
pci=["02:10.0,seize=1"]
```

Please note you need bring up physical device before attach it to DomU

Restart DomU. You should see a new `enp0s0` (or `eth1`) network device in DomU. This
is the virtual function of first Ethernet controller (pci device 01:00.0)
that resides in DomD.

## TSN1 pass-through

In this release TSN1 network interface is assigned to DomU. DomU still
used XEN PV Network for NFS boot, because this is more
convenient. DomU expects that TSN1 ip address will be assigned using
DHCP. User can provide own IP address by editing
`/etc/systemd/network/tsn1.network` file.

vmq0 interface is disabled in this release. But it can be enabled back
by un-commenting corresponding line in `/etc/xen/domu.cfg` file in
Dom0.

## PMU
Note, that this feature is not security supported because the PMU registers
are not virtualized and the physical registers are directly accessible when
this parameter is enabled.
see https://xenbits.xen.org/xsa/advisory-163.html.
It's not recommended to use it for production builds but it may be
used for development or debugging.
PMU is disabled by default. It can be enabled by by un-commenting corresponding
lines in `/etc/xen/domu.cfg` or `/etc/xen/domd.cfg` file in Dom0.
Also, this feature requires pinning CPUs to appropriate domain because
domain can migrate to different CPU during the execution that leading
to invalid counting by perf tool.

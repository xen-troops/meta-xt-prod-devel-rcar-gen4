# Overview

## Features

This release provides L3 routing offload feature for IPv4 based on S4 R-Switch MFWD. The feature adds hardware configuration to MFWD via FIB notifier in order to offload CPU and use MFWD mechanisms for routing.

Also, release contains partial support of traffic control filters HW offload. Now it is implemented for all TC filters - matchall, u32 and flower. The list of supported actions: drop and mirred redirect. Also, some acions are supported during redirect. It is dst MAC change (for u32 is performed by skbmod, for matchall and flower - by pedit) and VLAN ID / VLAN prio modifying for all filters.

For u32 and flower filters matching by all key parameters is supported: src/dst MACs, IPv4 addrs, IPv6 addrs, L4 ports, IP keys (ToS, TTL), basic keys (EtherType, Net proto). Also, VLAN 802.1Q (incl. 802.ad) tags matching (C-Tag and S-tag in MFWD terminology) is supported for flower. Matchall filter selects all frames by design.

**Vitrualization notice:** L3 routing and TC filters/actions offload is supported only for TSNx. By default, TSN1 is passed to DomU. But, if you want to make more complex setup and use offload on all TSNx you can leave TSN1 in DomD by comenting tsn1 line in [this config][].

[this config]: ../meta-xt-prod-devel-rcar-control-gen4/recipes-guests/domu/files/domu-vdevices.cfg

# Testing

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
sudo ip route add 192.168.3.0/24 via 192.168.1.2
sudo ip route add 192.168.5.0/24 via 192.168.1.2
```

### 2 PC

On main host, connected to TSN0:
```
sudo ip route add 192.168.3.0/24 via 192.168.1.2
sudo ip route add 192.168.5.0/24 via 192.168.1.2
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
192.168.1.0/24 dev tsn0 proto kernel scope link src 192.168.1.2 offload
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

Drop rule for IPv6 rule will look as follows:
```
tc filter add dev tsn0 protocol ipv6 parent ffff:0 u32 match ip6 src fe80::1ce0:30ff:fe47:aaaa action drop
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
tc filter add dev tsn0 protocol ipv6 parent ffff: flower skip_sw dst_ip fe80::2c09:aff:fe08:9851 action drop
tc filter add dev tsn2 parent ffff: protocol 802.1q flower skip_sw vlan_id 10 action drop
tc filter add dev tsn2 parent ffff: protocol 802.1ad flower skip_sw vlan_id 10 action drop
tc filter add dev tsn2 parent ffff: protocol 802.1ad flower skip_sw vlan_id 10 vlan_ethtype 802.1q cvlan_id 50 action drop
tc filter add dev tsn0 parent ffff:0 protocol ip flower dst_ip 192.168.20.0/24 action vlan modify id 20 pipe action pedit ex munge eth dst set 34:29:8f:75:c6:cc pipe action mirred egress redirect dev tsn1

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

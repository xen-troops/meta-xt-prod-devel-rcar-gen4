# IPS IDS offload

## Features

This setup provides all features from 0.8.8 S4 release and additionally supports offloaded IPS/IDS functionality.
For IPS/IDS feature used Snort with S4 R-Swtich specific DAQ module to block traffic using already offloaded
TC based method by the given verdict.

## rmonX devices
To process properly offloaded traffic that comes to some TSNX port and is forwarded to another port implemented
rmonX devices based on MFWD CPU mirroring. This needed to give a possibility to analyze traffic forwarded by hardware.
Every tsnX has appropriate rmonX device:
```
tsn0 --- rmon0
tsn1 --- rmon1
tsn2 --- rmon2
```

## IPS overview
Snort runs as a systemd service by init scripts for every TSNX port and analyzes traffic.
To start Snort for TSN, the appropriate interface link and rmon device should be up.
For example, to run Snort for TSN2 you have to run the following commands:
```
ifconfig tsn2 192.168.3.1 # place here needed IP
ifconfig rmon2 up
systemctl restart snort-tsn2
```

Snort can be stopped by the following command:
```
systemctl stop snort-tsn2
```

To update rules you can edit config file placed by default in `/etc/snort/snort.conf`. More information you can find at the [link](https://www.snort.org/documents).
Example of file with rules included in main config:

```
# /etc/snort/rules/local.rules content
# Drop any icmp packet
drop icmp any any -> $HOME_NET any (GID:1; sid:10000001;)
# Drop TCP packets with specified destination subnet IP and 5900 port
drop tcp any any -> 192.168.2.0/24 :5900 (GID:1; sid: 10000002;)
```
Include the file with rules to main config by adding the following line:
```
include $RULE_PATH/local.rules
```

After specified expiration timeout, the blacklist entry will be automatically removed. By default, this is 20 sec,
but you can change it by adding config `/etc/snort/rswitch.conf` file with the following content:
```
blacklist_expired_timeout: $TIMEOUT
```
Where $TIMEOUT is desired timeout in seconds.

#!/bin/bash

set -eux

### --start_docs
## Prepare network for deploying the overcloud
## ==================================================

## Prepare Your Environment
## ------------------------

## * Source in the undercloud credentials.
## ::

source /home/stack/stackrc

FENCING_RULE="-m udp -p udp -m multiport --dports 6230,6231 -m state --state NEW"
COMMENT="fencing_access_from_overcloud"
if ! sudo iptables -nvL INPUT | grep "$COMMENT"; then
    sudo iptables -I INPUT 1 $FENCING_RULE -m comment --comment "$COMMENT" -j ACCEPT
    sudo sh -c 'iptables-save > /etc/sysconfig/iptables'
fi




sudo bash -c 'cat <<EOF > /etc/sysconfig/network-scripts/ifcfg-vlan10
DEVICE=vlan10
ONBOOT=yes
DEVICETYPE=ovs
TYPE=OVSIntPort
BOOTPROTO=static
IPADDR=10.0.0.1
NETMASK=255.255.255.0
OVS_BRIDGE=br-ctlplane
OVS_OPTIONS="tag=10"
EOF'

sudo ifup ifcfg-vlan10





## * Set the DNS server in the control plane network
## ::

    neutron subnet-update $(neutron net-list | awk '/ctlplane/{print $(NF-2) }') $(awk 'match($0, /nameserver\s+(([0-9]{1,3}.?){4})/,address){printf " --dns-nameserver %s", address[1]}' /etc/resolv.conf)

### --stop_docs

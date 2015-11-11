#!/bin/bash

set -x
set -e

cat <<'EOS' | chroot $1 bash -c "cat | bash"
echo root:root | chpasswd

cat > /etc/sysconfig/network-scripts/ifcfg-eth1 <<EOF
DEVICE=eth1
TYPE=Ethernet
ONBOOT=yes
BOOTPROTO=static

IPADDR=10.0.0.1
NETMASK=255.255.255.0
EOF
EOS

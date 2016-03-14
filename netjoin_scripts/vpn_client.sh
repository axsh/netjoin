#!/bin/bash

set -x

yum -y install epel-release
yum -y install openvpn
curl -O http://dlc.openvnet.axsh.jp/packages/rhel/openvswitch/openvswitch-2.4.0-1.x86_64.rpm
yum -y localinstall openvswitch-2.4.0-1.x86_64.rpm

key_file=`ls /*.key`
mkdir -p /etc/openvpn
mv ${key_file} /etc/openvpn/
key_path=`ls /etc/openvpn/*.key`

remote_ip=`cat /remote_ip`

cat > /etc/openvpn/vpn.conf <<EOF
remote ${remote_ip}
float
port 1194
dev tap0
persist-tun
persist-key
comp-lzo
user nobody
group nobody
log vpn.log
verb 3
resolv-retry infinite
secret ${key_path}
EOF

service openvpn stop || :
service openvpn start
service openvswitch start

ovs-vsctl --if-exists del-br brtun
ovs-vsctl --may-exist add-br brtun
ovs-vsctl --if-exists del-port brtun tap0
ovs-vsctl --may-exist add-port brtun tap0
ip link set brtun up
ip link set tap0 up

#!/bin/bash

name=$1
cidr_global=$2
num=`shuf -i 10-99 -n 1`

bridge_internal='brint'
bridge_global='brglo'

eth0="${name}-eth0"
eth1="${name}-eth1"

/usr/libexec/qemu-kvm \
  -name ${name} -cpu qemu64,+vmx -m 128 -smp 1 \
  -vnc 127.0.0.1:110${num} -k en-us -rtc base=utc \
  -monitor telnet:127.0.0.1:140${num},server,nowait \
  -serial telnet:127.0.0.1:150${num},server,nowait \
  -serial file:console.log \
  -drive file=./centos-6.7_x86_64.raw,media=disk,boot=on,index=0,cache=none,if=virtio \
  -netdev tap,ifname=${eth0},id=hostnet0,script=,downscript= \
  -device virtio-net-pci,netdev=hostnet0,mac=52:54:00:00:00:00,bus=pci.0,addr=0x3 \
  -netdev tap,ifname=${eth1},id=hostnet1,script=,downscript= \
  -device virtio-net-pci,netdev=hostnet1,mac=52:54:00:00:00:01,bus=pci.0,addr=0x4 \
  -pidfile kvm.pid -daemonize -enable-kvm

brctl addbr ${bridge_global} || :
brctl addif ${bridge_global} ${eth0}
ip addr add ${cidr_global} dev ${bridge_global} || :
ip link set ${bridge_global} up
ip link set ${eth0} up

brctl addbr ${bridge_internal} || :
brctl addif ${bridge_internal} ${eth1}
ip link set ${bridge_internal} up
ip link set ${eth1} up

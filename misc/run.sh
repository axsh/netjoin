#!/bin/bash

name=$1
num=`shuf -i 10-99 -n 1`

/usr/libexec/qemu-kvm \
  -name ${name} -cpu qemu64,+vmx -m 128 -smp 1 \
  -vnc 127.0.0.1:110${num} -k en-us -rtc base=utc \
  -monitor telnet:127.0.0.1:140${num},server,nowait \
  -serial telnet:127.0.0.1:150${num},server,nowait \
  -serial file:console.log \
  -drive file=./centos-6.7_x86_64.raw,media=disk,boot=on,index=0,cache=none,if=virtio \
  -netdev tap,ifname=client12-eth0,id=hostnet0,script=,downscript= \
  -device virtio-net-pci,netdev=hostnet0,mac=52:54:00:00:00:00,bus=pci.0,addr=0x3 \
  -pidfile kvm.pid -daemonize -enable-kvm

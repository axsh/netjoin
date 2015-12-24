# -*- coding: utf-8 -*-

require 'net/ssh'
require 'net/scp'
require 'ipaddr'
require 'sshkey'

module Netjoin::Drivers
  module Kvm
    extend Netjoin::Helpers::Logger

    def self.create(node)



      if node.parent && node.parent != 'self'
        parent = Netjoin::Models::Nodes.new(name: node.parent)
        k = SSHKey.new(File.read(node.ssh_privatekey))

        Net::SSH.start(parent.ssh_ip_address, parent.ssh_user, :keys => [parent.ssh_privatekey]) do |ssh|
          net = IPAddr.new("#{node.ssh_ip_address}/#{node.prefix}")

          work_dir = if parent.ssh_user == 'root'
                       "/root/netjoin_workspace"
                     else
                       "/home/#{parent.ssh_user}/netjoin_workspace"
                     end

          sudo = if parent.ssh_user != 'root'
                   "sudo"
                 else
                   ""
                 end

          commands = []
          commands << "mkdir -p #{work_dir} || :"
          commands << generate_execscript(work_dir, k)
          commands << generate_runscript(work_dir)
          commands << create_and_launch_kvm(sudo, work_dir, node)

          commands << "#{sudo} iptables -t nat -A POSTROUTING -s #{net.to_s}/#{node.prefix} -j MASQUERADE || :"
          commands << "#{sudo} iptables -D FORWARD -j REJECT --reject-with icmp-host-prohibited || :"
          commands << "#{sudo} sysctl -n -e net.ipv4.ip_forward=1"

          ssh_exec(ssh, commands)
        end
      elsif node.parent == 'self'
        info "self"
        # generate_execscript(work_dir,k)
        # generate_runscript(work_dir)
        # create_and_launch_kvm(work_dir, node)

        # net = IPAddr.new("#{node.ssh_ip_address}/#{node.prefix}")
        # `#{sudo} iptables -t nat -A POSTROUTING -s #{net.to_s}/#{node.prefix} -j MASQUERADE || :`
        # `#{sudo} iptables -D FORWARD -j REJECT --reject-with icmp-host-prohibited || :`
        # `#{sudo} sysctl -n -e net.ipv4.ip_forward=1`
      else
        error 'specify node.parent'
        return
      end
    end

    private

    def self.create_and_launch_kvm(sudo, work_dir, node)

      bridge_ip = IPAddr.new(IPAddr.new("#{node.ssh_ip_address}/24").to_i+1, Socket::AF_INET)

      commands = []
      commands << "cd #{work_dir}"
      commands << "#{sudo} yum -y install git parted kpartx bridge-utils || :"
      commands << "git clone https://github.com/hansode/vmbuilder.git || :"
      commands << "cd vmbuilder/kvm/rhel/6/"
      commands << "#{sudo} ./vmbuilder.sh \
                              --ip=#{node.ssh_ip_address} \
                              --mask=255.255.255.0 \
                              --gw=#{bridge_ip} \
                              --execscript=#{work_dir}/execscript.sh"
      commands << "#{sudo} mv centos-6.7_x86_64.raw #{work_dir}"
      commands << "cd #{work_dir}"
      commands << "#{sudo} ./run.sh #{node.name} #{bridge_ip}/#{node.prefix}"
      commands
    end

    def self.generate_runscript(work_dir)
"cat > #{work_dir}/run.sh <<EOEXEC
#!/bin/bash

name=\\$1
cidr_global=\\$2
num=`shuf -i 10-99 -n 1`
kvm_cmd=
path=`which qemu-kvm`
if [ $? -eq 1 ]; then
  kvm_cmd=`whereis qemu-kvm | awk '{print $2}'`
else
  kvm_cmd=\\${path}
fi

bridge_internal='brint'
bridge_global='brglo'

eth0=\\${name}-eth0
eth1=\\${name}-eth1

\\${kvm_cmd} \
  -name \\${name} -cpu qemu64,+vmx -m 128 -smp 1 \
  -vnc 127.0.0.1:110\\${num} -k en-us -rtc base=utc \
  -monitor telnet:127.0.0.1:140\\${num},server,nowait \
  -serial telnet:127.0.0.1:150\\${num},server,nowait \
  -serial file:console.log \
  -drive file=./centos-6.7_x86_64.raw,media=disk,boot=on,index=0,cache=none,if=virtio \
  -netdev tap,ifname=\\${eth0},id=hostnet0,script=,downscript= \
  -device virtio-net-pci,netdev=hostnet0,mac=52:54:00:00:00:00,bus=pci.0,addr=0x3 \
  -netdev tap,ifname=\\${eth1},id=hostnet1,script=,downscript= \
  -device virtio-net-pci,netdev=hostnet1,mac=52:54:00:00:00:01,bus=pci.0,addr=0x4 \
  -pidfile kvm.pid -daemonize -enable-kvm

brctl addbr \\${bridge_global} || :
brctl addif \\${bridge_global} \\${eth0}
ip addr add \\${cidr_global} dev \\${bridge_global} || :
ip link set \\${bridge_global} up
ip link set \\${eth0} up

brctl addbr \\${bridge_internal} || :
brctl addif \\${bridge_internal} \\${eth1}
ip link set \\${bridge_internal} up
ip link set \\${eth1} up
EOEXEC
chmod +x #{work_dir}/run.sh"
    end

    def self.generate_execscript(work_dir, k)
"cat > #{work_dir}/execscript.sh <<EOEXEC
#!/bin/bash

set -x
set -e

cat <<'EOS' | chroot \\$1 bash -c 'cat | bash'

cat > /etc/sysconfig/network-scripts/ifcfg-eth1 <<EOF
DEVICE=eth1
TYPE=Ethernet
ONBOOT=yes
BOOTPROTO=static

IPADDR=10.0.0.1
NETMASK=255.255.255.0
EOF

curl -L -o openvswitch.rpm https://www.dropbox.com/s/y1cb03vy4cxiru7/openvswitch-2.4.0-1.x86_64.rpm?dl=0
yum -y localinstall openvswitch.rpm
chkconfig openvswitch on

mkdir /root/.ssh

cat > /root/.ssh/authorized_keys <<EOF
#{k.ssh_public_key.chomp}
EOF
chmod 600 /root/.ssh/authorized_keys
EOS
EOEXEC
chmod +x #{work_dir}/execscript.sh"
    end
  end
end

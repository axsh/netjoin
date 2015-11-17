# -*- coding: utf-8 -*-

require 'net/ssh'
require 'net/scp'
require 'ipaddr'

module Netjoin::Drivers
  module Kvm
    extend Netjoin::Helpers::Logger

    def self.create(node)
      if node.ssh_from
        ip = node.ssh_from['ssh_ip_address']
        user = node.ssh_from['ssh_user']
        password = node.ssh_from['ssh_password']

        run_script = "#{Netjoin::ROOT}/misc/run.sh"
        exec_script = "#{Netjoin::ROOT}/misc/execscript.sh"

        Net::SCP.upload!(ip, user, run_script, "/root", :ssh => {:password => password})
        Net::SCP.upload!(ip, user, exec_script, "/root", :ssh => {:password => password})

        Net::SSH.start(ip, user, :password => password) do |ssh|
          if node.provision
            info ssh.exec!("chmod +x ./execscript.sh")
            info ssh.exec!("chmod +x ./run.sh")

            bridge_ip = IPAddr.new(IPAddr.new("#{node.ssh_ip_address}/24").to_i+1, Socket::AF_INET)

            info ssh.exec!("yum -y install git parted kpartx bridge-utils || :")
            info ssh.exec!("git clone https://github.com/hansode/vmbuilder.git || :")
            info ssh.exec!("cd vmbuilder/kvm/rhel/6/; ./vmbuilder.sh --ip=#{node.ssh_ip_address} --mask=255.255.255.0 --gw=#{bridge_ip} --execscript=/root/execscript.sh; mv centos-6.7_x86_64.raw /root")

            info ssh.exec!("./run.sh #{node.name} #{bridge_ip}/#{node.prefix}")
          end

          net = IPAddr.new("#{node.ssh_ip_address}/#{node.prefix}")
          info ssh.exec!("iptables -t nat -A POSTROUTING -s #{net.to_s}/#{node.prefix} -j MASQUERADE || :")
          info ssh.exec!("iptables -D FORWARD -j REJECT --reject-with icmp-host-prohibited || :")
          info ssh.exec!("sysctl -n -e net.ipv4.ip_forward=1")
        end
      end
    end
  end
end

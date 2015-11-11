# -*- coding: utf-8 -*-

require 'bcrypt'
require 'net/ssh'
require 'net/scp'
require 'ipaddr'

module Netjoin::Models
  class Nodes < Base
    include Netjoin::Helpers::Logger

    def self.validate(options)
      options['prefix'] = 24 if options['prefix'].nil?
      #encrypt_password(options)
    end

    def create
      if self.ssh_from
        ip = self.ssh_from['ssh_ip_address']
        user = self.ssh_from['ssh_user']
        password = self.ssh_from['ssh_password']

        run_script = "#{Netjoin::ROOT}/misc/run.sh"
        exec_script = "#{Netjoin::ROOT}/misc/execscript.sh"

        Net::SCP.upload!(ip, user, run_script, "/root", :ssh => {:password => password})
        Net::SCP.upload!(ip, user, exec_script, "/root", :ssh => {:password => password})

        Net::SSH.start(ip, user, :password => password) do |ssh|
          if self.provision
            info ssh.exec!("chmod +x ./execscript.sh")
            info ssh.exec!("chmod +x ./run.sh")

            bridge_ip = IPAddr.new(IPAddr.new("#{self.ssh_ip_address}/24").to_i+1, Socket::AF_INET)

            info ssh.exec!("yum -y install git parted kpartx bridge-utils || :")
            info ssh.exec!("git clone https://github.com/hansode/vmbuilder.git || :")
            info ssh.exec!("cd vmbuilder/kvm/rhel/6/; ./vmbuilder.sh --ip=#{self.ssh_ip_address} --mask=255.255.255.0 --gw=#{bridge_ip} --execscript=/root/execscript.sh; mv centos-6.7_x86_64.raw /root")

            info ssh.exec!("./run.sh #{self.name} #{bridge_ip}/#{self.prefix}")
          end

          net = IPAddr.new("#{self.ssh_ip_address}/#{self.prefix}")
          ssh.exec!("iptables -t nat -A POSTROUTING -s #{net.to_s}/#{self.prefix} -j MASQUERADE || :")
          ssh.exec!("iptables -D FORWARD -j REJECT --reject-with icmp-host-prohibited || :")
        end
      end
    end

    private

    def shape(hash, params)
      node = hash['nodes'][params[:name]]
      if node['ssh_from']
        ssh_from = node['ssh_from']
        node['ssh_from'] = hash['nodes'][ssh_from]
      end
      node['name'] = params[:name]
      node
    end

    def self.encrypt_password(options)
      return if not options['ssh_password']
      options['ssh_password'] = ::BCrypt::Password.create(options['ssh_password']).to_s
    end
  end
end

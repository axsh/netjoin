# -*- coding: utf-8 -*-

require 'bcrypt'
require 'net/ssh'
require 'net/scp'

module Netjoin::Models
  class Nodes < Base
    include Netjoin::Helpers::Logger

    def self.validate(options)
      #encrypt_password(options)
    end

    def create
      if self.ssh_from
        ip = self.ssh_from['ssh_ip_address']
        user = self.ssh_from['ssh_user']
        password = self.ssh_from['ssh_password']
        fp = "#{Netjoin::ROOT}/misc/run.sh"
        Net::SCP.upload!(ip, user, fp, "/root", :ssh => {:password => password})
        Net::SSH.start(ip, user, :password => password) do |ssh|
          if self.provision
            info ssh.exec!("yum -y install git parted kpartx bridge-utils || :")
            info ssh.exec!("git clone https://github.com/hansode/vmbuilder.git || :")
            info ssh.exec!("cd vmbuilder/kvm/rhel/6/; ./vmbuilder.sh --ip=10.100.0.10 --mask=255.255.255.0; mv centos-6.7_x86_64.raw /root")
            info ssh.exec!("chmod +x ./run.sh; ./run.sh #{self.name}")
          end
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

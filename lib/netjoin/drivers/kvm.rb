# -*- coding: utf-8 -*-

require 'net/ssh'
require 'net/scp'
require 'sshkey'

module Netjoin::Drivers
  module Kvm
    extend Netjoin::Helpers::Logger

    def self.create(node_name)
      node = db[:nodes][node_name]

      if node[:ssh].key?(:from)

        parent_name = node[:ssh][:from].to_sym
        parent = Netjoin.db[:nodes][parent_name]

        if parent[:ssh].key?(:sudo_password) && parent[:ssh][:sudo_password] == true
          info "Enter password: "
          password = STDIN.noecho(&:gets).chomp
        end

        work_dir = if parent[:ssh][:user] == 'root'
                     "/root/netjoin_workspace"
                   else
                     "/home/#{parent[:ssh][:user]}/netjoin_workspace"
                   end

        kvm_dir        = work_dir + "/" + node_name.to_s
        kvm_rootfs_dir = work_dir + "/" + node_name.to_s + "/rootfs"


        Net::SSH.start(parent[:ssh][:ip], parent[:ssh][:user], :keys => [ parent[:ssh][:key] ]) do |ssh|

          commands = []
          commands << "mkdir -p #{work_dir} || :"
          commands << "mkdir -p #{kvm_dir} || :"
          commands << "mkdir -p #{kvm_rootfs_dir} || :"
          commands << "mkdir -p #{kvm_rootfs_dir}/etc/sysconfig/network-scripts/ || :"
          commands << "mkdir -p #{kvm_rootfs_dir}/root/ || :"
          commands << "mkdir -p #{kvm_rootfs_dir}/root/.ssh || :"

          ssh_exec(ssh, commands)
        end

        f_mac = File.open("macaddress", "w")
        f_bridge = File.open("bridge", "w")
        f_remote_ip = File.open("remote_ip", "w")

        nic_num = 0
        node[:provision][:spec][:nics].each do |key, value|
          f_mac.puts value[:mac_address]
          f_bridge.puts db[:networks][value[:network].to_sym][:bridge_name]

          ifcfg_file = File.open("ifcfg-eth#{nic_num}", "w")

          value.each do |k, v|
            next if k == :network
            next if k == :mac_address
            ifcfg_file.puts "#{k.to_s.upcase}=#{v}"
          end

          ifcfg_file.close
          nic_num = nic_num + 1
        end

        f_remote_ip.write get_remote_ip

        f_mac.close
        f_bridge.close
        f_remote_ip.close

        Net::SCP.start(parent[:ssh][:ip], parent[:ssh][:user], :keys => [ parent[:ssh][:key] ]) do |scp|
          scp.upload!("#{Netjoin::ROOT}/netjoin_scripts/seed_download.sh", work_dir)
          scp.upload!("#{Netjoin::ROOT}/netjoin_scripts/kvm.sh", kvm_dir)
          scp.upload!("#{Netjoin::ROOT}/netjoin_scripts/vpn_client.sh", kvm_rootfs_dir)
          scp.upload!("#{Netjoin::ROOT}/netjoin_scripts/firstboot.sh", "#{kvm_rootfs_dir}/root")
          scp.upload!("macaddress", kvm_dir)
          scp.upload!("bridge", kvm_dir)
          scp.upload!("remote_ip", kvm_rootfs_dir)

          for i in 0..nic_num-1
            scp.upload("ifcfg-eth#{i}", "#{kvm_rootfs_dir}/etc/sysconfig/network-scripts/")
          end

          if config[:vpn_key]
            scp.upload!(config[:vpn_key], kvm_rootfs_dir)
          else
            scp.upload!("#{Netjoin::ROOT}/keys/insecure_vpn.key", kvm_rootfs_dir)
          end

          k = SSHKey.new(File.read(node[:ssh][:key]))
          File.open("authorized_keys", "w") do |f|
            f.write k.ssh_public_key
          end
          scp.upload!("authorized_keys", "#{kvm_rootfs_dir}/root/.ssh")
          FileUtils.rm("authorized_keys")
        end

        FileUtils.rm("macaddress")
        FileUtils.rm("bridge")

        for i in 0..nic_num-1
          FileUtils.rm("ifcfg-eth#{i}")
        end

        Net::SSH.start(parent[:ssh][:ip], parent[:ssh][:user], :keys => [ parent[:ssh][:key] ]) do |ssh|
          ssh_exec(ssh, [
            "chmod +x #{work_dir}/*.sh",
            "chmod +x #{kvm_dir}/*.sh",
            "chmod +x #{kvm_rootfs_dir}/*.sh",
            "chmod +x #{kvm_rootfs_dir}/root/*.sh",
            "chmod 700 #{kvm_rootfs_dir}/root/.ssh",
            "chmod 600 #{kvm_rootfs_dir}/root/.ssh/authorized_keys",
            "sudo chown root.root #{kvm_rootfs_dir}/*",
            "sudo chown root.root #{kvm_rootfs_dir}/root/.ssh",
            "sudo chown root.root #{kvm_rootfs_dir}/root/.ssh/authorized_keys",
            "sudo chmod g-w #{kvm_rootfs_dir}/root",
            "chown #{node[:ssh][:user]}.#{node[:ssh][:user]} #{kvm_dir}/*.sh",
            "#{work_dir}/seed_download.sh",
          ])

          ssh_exec(ssh,[
            "sudo #{kvm_dir}/kvm.sh #{node_name.to_s} \
            #{node[:provision][:spec][:disk]} \
            #{node[:provision][:spec][:memory]}"
          ])
        end

      elsif node.parent == 'self'
        info "self"
      else
        error 'specify node.parent'
        return
      end
    end

    private

    def self.get_remote_ip
      d = db[:nodes].select {|k,v| v.key?(:provision) && v[:provision][:spec][:type] == 'aws'}
      d.first.last[:ssh][:ip]
    end
  end
end

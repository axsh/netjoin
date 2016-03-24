
### Networks

```yaml
linux_internal:
  network_type: linux
  bridge_name: brlocal
aws:
  network_type: vpc
  subnet_id: subnet-xxxxx
```

- `network_type` : `linux` or `vpc` (required)
- `bridge_name` : The name of a linux/ovs bridge only if `linux` is specified as `network_type` (required)
- `subnet_id` : The uuid of subnet on Amazon VPC (optional)

### Nodes

```yaml
node1:
  provision:
    provisioned: false
    spec:
      type: aws
      instance_type: t2.micro
      key_pair: keypair
      nics:
        eth0:
          networks: aws
          ipaddr: 192.168.1.xx
      instance_id: i-xxxxx
      public_ip_address: 52.xx.xx.xx
      subnet: subnet-xxxxx
  ssh:
    user: ec2-user
    key: "/path/to/key.pem"
    ip: 52.xx.xx.xx
bare_metal:
  ssh:
    ip: xx.yy.zz.ff
    user: sample_user
    key: "/path/to/key_for_bare_metal.pem"
    sudo_password: false
node2:
  provision:
    provisioned: false
    spec:
      type: kvm
      disk: 10
      memory: 4000
      nics:
        eth0:
          network: linux_internal
          device: eth0
          bootproto: static
          onboot: 'yes'
          ipaddr: 10.100.0.2
          prefix: 24
          gateway: 10.100.0.1
          defroute: 'yes'
          mac_address: 52:54:00:FF:00:00
  ssh:
    from: bare_metal
    ip: aa.bb.cc.dd
    user: root
    key: "/path/to/key_for_kvm.pem"
```

- `provision`: netjoin provisions a node if it includes this parameter
- `provisioned`: netjoin writes `true` after it provisions the node. Set `false` or delete this parameter if you want to provision this node again
- `type` : `kvm` or `aws`
- `disk` : disk size to expand in GB
- `memory`: memory size in MB
- `nics`: detail information for network interfaces
- `network`: network name specified in `networks` to join
- `from`: The node which this node can be accessed from
- `ip`: IP address for ssh
- `user`: ssh user
- `key`: ssh key

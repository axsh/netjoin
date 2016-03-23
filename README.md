
# Netjoin

Netjoin is a toolset to allow users to create VPN networks as they need.

**Disclaimer** : This CLI does not maintain the VPN network once it has been set up!

The first version only works with the Linux clients and the OpenVPN.

# Requirements

* CentOS 6.6

* Configuration for IP masquerade

Netjoin creates KVM instances on a given physical host. At least one network interface of the KVM instance should be accessible to the Internet. Netjoin requires `iptables` and ip forward are already configured.

# Setup

```bash
$ git clone https://github.com/axsh/netjoin.git
$ cd path/to/repo
$ bundle install --path vendor/bundle
$ bundle exec ./bin/netjoin init
```

# How to use

Define nodes

```bash
$ bundle exec ./bin/netjoin nodes add node-name \
  --type kvm \
  --ssh-ip-address 192.168.100.100 \
  --prefix 24 \
  --ssh-password vulnerablepassword \
  --ssh-pem pemfilename.pem \
  --ssh-from parent-node-name \
  --provision true # if this node is not created yet \
  --access-key-id ACCESSKEYIDFORAWSIFTYPEISAWS \
  --secret-key AWSSECRETKEY \
  --ami ami-abcdefg \
  --instance-type t2.foobar \
  --key-pair registered-key-pair \
  --region aws-region \
  --security-groups [sg-aaaa, sg-bbbb] \
  --vpc-id vpc-aaaa \
  --zone aws-zone
```

Define networks

```bash
$ bundle exec ./bin/netjoin networks add network-name \
  --driver openvpn \
  --type site-to-site # or client-to-client \
  --server-nodes [node1, node2, node3] \
  --client-nodes [client1, client2] \
  --psk /path/to/psk.psk
```

Provision nodes

```bash
$ bundle exec ./bin/netjoin nodes create node-name
```

Provision networks

```bash
$ bundle exec ./bin/netjoin networks create network-name
```


# Misc

Netjoin uses the default credentials in `test/keys` directory if no credentials specified in `database.yml`.
If you want to prepare your own credentials for VPN networks,
This [tutorial](https://www.digitalocean.com/community/tutorials/how-to-setup-and-configure-an-openvpn-server-on-centos-6)
of EasyRSA gives you a simple yet clear way to create required credentials.

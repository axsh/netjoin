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
$ cd /path/to/repo
$ bundle install --path vendor/bundle --standalone
$ PATH=/path/to/repo/bin:$PATH
```

# How to use

Create a working directory.

```bash
$ mkdir /path/to/your/work_dir
```

Initialize netjoin.

```bash
$ cd /path/to/your/work_dir
$ netjoin init
```

`netjoin init` generates the following files:
- `netjoin.yml`
- `netjoin_config.yml`

Edit the files then hit the following.

```bash
$ netjoin up
```


# Misc

Netjoin uses `keys/insecure_vpn.key` as the default vpn key if nothing is specified in `netjoin_config.yml`.
If you want to prepare your own credentials for VPN networks,
This [tutorial](https://www.digitalocean.com/community/tutorials/how-to-setup-and-configure-an-openvpn-server-on-centos-6)
of EasyRSA gives you a simple yet clear way to create required credentials.

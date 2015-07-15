# ducttape
Name provisional, WIP

A CLI to allows you to specify a VPN network layout. Add clients to a database file and later attach it to a VPN network.

First version will only work with Linux clients and OpenVPN. An OpenVPN server will need to be manually set up to be used by Ducttape. Ducttape will connecto to the server to generate the VPN certificates.

# Setup

Clone this repository.

Initialize ducttape to create the config and database files by the following command :

```bash
$ bin/ducttape init
```

# VPN Server

## Linux - OpenVPN

Set up using following guide : [https://www.digitalocean.com/community/tutorials/how-to-setup-and-configure-an-openvpn-server-on-centos-6]

Remove  ``--interact`` from the ``build-key`` script. 

# VPN Clients

## Linux

Works with OpenVPN

### Supported OS :

* CentOS 6.6

## AWS

Not yet supported!

Installation of the [Amazon EC2 CLI Tools](http://docs.aws.amazon.com/AWSEC2/latest/CommandLineReference/set-up-ec2-cli-linux.html) is required to work with Amazon EC2

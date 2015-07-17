# ducttape
Name provisional, WIP

A CLI to allows you to specify and build a VPN network layout. Using the CLI you can servers and clients to a database file which will later be used to set up the VPN network. 

**Disclaimer** : This CLI does not maintain the VPN network once it has been set up!

First version will only work with Linux clients and OpenVPN. A pre-installed OpenVPN server is required. Ducttape will connect to the server to generate the VPN certificates.

### Prerequisites

* A server running CentOS with OpenVPN installed and configured with Easy-RSA

See guide : https://www.digitalocean.com/community/tutorials/how-to-setup-and-configure-an-openvpn-server-on-centos-6

## VPN Server

### Linux - OpenVPN

Set up using following guide : [https://www.digitalocean.com/community/tutorials/how-to-setup-and-configure-an-openvpn-server-on-centos-6]

Remove  ``--interact`` from the ``build-key`` script. 

## VPN Clients

### Linux

Works with OpenVPN and Easy-RSA

#### Supported OS :

* CentOS 6.6

### AWS

Not yet supported!

# Setup

Clone this repository.

Initialize ducttape to create the config and database files by the following command :

```bash
$ bin/ducttape init
```

# Quick introduction

## Add a server

```bash
$ ducttape servers linux add vpn-server-name --ip-address 192.168.122.100 --mode dynamic --network 10.8.0.0/24 --username root --password root
```

## Add a client

```bash
$ ducttape clients linux add vpn-client-name --server vpn-server-name --ip-address 192.168.122.165 --username root --password root 
```

## Attach the client to the VPN network

```bash
$ ducttape clients attach
```
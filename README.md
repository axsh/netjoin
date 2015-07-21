# ducttape
Name provisional, WIP

A CLI to allows you to specify and build a VPN network layout. Using the CLI you can servers and clients to a database file which will later be used to set up the VPN network. 

**Disclaimer** : This CLI does not maintain the VPN network once it has been set up!

First version will only work with Linux clients and OpenVPN.

## VPN Server

### Linux - OpenVPN

Works with OpenVPN (optionally with Easy-RSA for key generation)

#### Supported OS :

* CentOS 6.6 

## VPN Clients

### Linux - OpenVPN

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

# Quick start with Easy-RSA

When you just want a quick and simple way of setting up your OpenVPN network

### Prerequisites

* Running server and client on CentOS 6.6 with OpenVPN installed and configured with Easy-RSA

Set up server using following guide : [https://www.digitalocean.com/community/tutorials/how-to-setup-and-configure-an-openvpn-server-on-centos-6]

Remove  ``--interact`` from the ``build-key`` script. 

## Add a server

Server has OpenVPN already installed and configured using the above guide

```bash
$ ducttape servers linux add vpn-server-name --ip-address 192.168.122.100 --mode dynamic --network 10.8.0.0/24 --username root --password root
```

## Add a client

```bash
$ ducttape clients linux add vpn-client-name --server vpn-server-name --ip-address 192.168.122.165 --username root --password root 
```

## Attach the client to the VPN network

Installs OpenVPN, generates certification file, uploads the file to the client and starts OpenVPN using that file 

```bash
$ ducttape clients attach
```

# More advanced setup

When you take care of generating the configuration and certification files yourself

### Prerequisites

* Running server and client on CentOS 6.6
* Have the `<vpn-client-name>.ovpn` file located in `keys` folder
* Have the server config and certification files ready in `/tmp/` or another folder (edit below line as needed)
  * server.conf
  * ca.crt
  * dh2048.pem
  * server.crt
  * server.key

## Add server

```bash
$ ducttape servers linux add vpn-server --ip-address 192.168.122.100 --mode dynamic --network 10.8.0.0/24 --username root --password root --file-conf /tmp/server.conf --file-ca-crt /tmp/ca.crt --file-pem /tmp/dh2048.pem --file-crt /tmp/server.crt --file-key /tmp/server.key
```

## Install server

Installs OpenVPN, uploads the configuration and certification files and starts OpenVPN

```bash
$ ducttape servers linux install vpn-server
```

## Add client 

```bash
$ ducttape clients linux add vpn-client-name --server vpn-server-name --ip-address 192.168.122.165 --username root --password root --generate-key true
```

## Attach client

Installs OpenVPN, uploads the local certification file  to the client and starts OpenVPN using that file 

```bash
$ ducttape clients attach
```

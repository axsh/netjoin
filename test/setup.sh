#!/bin/bash

set -e
set -o pipefail
set -x

# jenkins defines "WORKSPACE"
cd "${WORKSPACE:-"/home/vagrant/ducttape"}"
bundle install

echo "#### Initializing ducttape"
bin/ducttape init

echo "#### Adding Server"
bin/ducttape servers linux add server1 --ip-address 192.168.56.10 --username vagrant --key-pem test/keys/insecure_private_key --file-ca-crt test/keys/ca.crt --file-conf test/keys/server.conf --file-crt test/keys/server.crt --file-key test/keys/server.key --file-pem test/keys/dh2048.pem

echo "#### Adding Client"
bin/ducttape clients linux add client3 --server server1 --ip-address 192.168.56.100 --username vagrant --key-pem test/keys/insecure_private_key --file_key test/keys/client1.ovpn

echo "#### Installing Server"
bin/ducttape servers linux install server1

echo "#### Attaching Client"
bin/ducttape clients attach

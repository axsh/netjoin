cd /home/vagrant/ducttape
bundle install

bin/ducttape servers linux add server1 --ip-address 192.168.56.10 --username vagrant --password vagrant --file-ca-crt test/keys/ca.crt --file-conf test/keys/server.conf --file-crt test/keys/server.crt --file-key test/keys/server.key --file-pem test/keys/dh2048.pem
bin/ducttape clients linux add client1 --server server1 --ip-address 192.168.56.100 --username vagrant --password vagrant --file_key test/keys/client.ovpn

bin/ducttape servers linux install server1

bin/ducttape clients attach

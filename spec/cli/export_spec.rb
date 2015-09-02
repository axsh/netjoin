require 'spec_helper'

describe Netjoin::Cli::Root do

  context "Export" do

    context "All" do
      let(:output) { capture(:stdout) { subject.export } }

      it "contains all the database content" do
        expect(output).to eql "---
servers:
  vpn-server-1:
    :type: :linux
    :data:
      :configured: true
      :file_ca_crt: \"/tmp/ca.crt\"
      :file_conf: \"/tmp/server.conf\"
      :file_crt: \"/tmp/server.crt\"
      :file_key: \"/tmp/server.key\"
      :file_pem: \"/tmp/server.pem\"
      :installed: true
      :ip_address: 225.79.101.15
      :key_pem: \"/tmp/user.pem\"
      :mode: dynamic
      :network_ip: 10.8.0.0
      :network_prefix: 32
      :password: test123
      :port:#{' '}
      :username: root
  aws-server-1:
    :type: :aws
    :data:
      :configured: true
      :file_ca_crt: \"/tmp/ca.crt\"
      :file_conf: \"/tmp/server.conf\"
      :file_crt: \"/tmp/server.crt\"
      :file_key: \"/tmp/server.key\"
      :file_pem: \"/tmp/server.pem\"
      :installed: true
      :ip_address: 55.29.16.157
      :key_pem: \"/tmp/ec2_test.pem\"
      :mode: dynamic
      :network_ip:#{' '}
      :network_prefix:#{' '}
      :password:#{' '}
      :port:#{' '}
      :username: ec2-user
      :access_key_id: AMAZONAWSEC2ACCESKEY
      :ami: ami-12345678
      :instance_id: i-12345678
      :instance_type: t2.micro
      :key_pair: aws_keypair_name
      :private_ip_address: 172.32.45.159
      :public_dns_name: ec2-55-19-16-157.us-west-2.compute.amazonaws.com
      :region: us-west-2
      :secret_key: AmazonAwsEC2SecretKey
      :security_groups:
      - sg-12345678
      - sg-87654321
      :vpc_id: vpc-87654321f
      :zone: us-west-2a
  softlayer-server-1:
    :type: :softlayer
    :data:
      :configured: true
      :file_ca_crt: \"/tmp/ca.crt\"
      :file_conf: \"/tmp/server.conf\"
      :file_crt: \"/tmp/server.crt\"
      :file_key: \"/tmp/server.key\"
      :file_pem: \"/tmp/server.pem\"
      :installed: true
      :ip_address: 161.232.155.142
      :key_pem:#{' '}
      :mode: dynamic
      :network_ip:#{' '}
      :network_prefix:#{' '}
      :password: root
      :port: '1194'
      :username: root
      :domain: example.com
      :hostname: netjoin
      :instance_id: 163024005
      :ssl_api_key: SoftLayerSSLAPIKey
      :ssl_api_username: ssl_username
clients:
  vpn-client-10:
    :type: :linux
    :server: vpn-server-1
    :status: :new
    :error:#{' '}
    :data:
      :generate_key: true
      :file_key:#{' '}
      :ip_address: 88.159.47.22
      :key_pem:#{' '}
      :password: test123
      :username: root
      :vpn_ip_address:#{' '}
  vpn-client-99:
    :type: :linux
    :server: vpn-server-1
    :status: :new
    :error:#{' '}
    :data:
      :generate_key: true
      :file_key:#{' '}
      :ip_address: 204.99.63.105
      :key_pem: \"/tmp/user.pem\"
      :password:#{' '}
      :username: root
      :vpn_ip_address:#{' '}
  aws-client-01:
    :type: :linux
    :server: aws-server-1
    :status: :new
    :error:#{' '}
    :data:
      :generate_key: false
      :file_key: \"/tmp/client-1.ovpn\"
      :ip_address: 188.59.47.122
      :key_pem:#{' '}
      :password: test123
      :username: root
      :vpn_ip_address:#{' '}
  aws-client-02:
    :type: :linux
    :server: aws-server-1
    :status: :new
    :error:#{' '}
    :data:
      :generate_key: false
      :file_key: \"/tmp/client-2.ovpn\"
      :ip_address: 214.93.163.15
      :key_pem: \"/tmp/user.pem\"
      :password:#{' '}
      :username: root
      :vpn_ip_address:#{' '}
  softlayer-client-01:
    :type: :linux
    :server: softlayer-server-1
    :status: :new
    :error:#{' '}
    :data:
      :generate_key: false
      :file_key: \"/tmp/client-1.ovpn\"
      :ip_address: 21.93.16.152
      :key_pem: \"/tmp/user.pem\"
      :password:#{' '}
      :username: root
      :vpn_ip_address:#{' '}
"
      end
    end # End context All

  end # End context Export

end
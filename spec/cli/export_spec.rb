require 'spec_helper'

describe Ducttape::Cli::Root do

  context "Export" do

    context "All" do
      let(:output) { capture(:stdout) { subject.export } }

      it "contains all the database content" do
        expect(output).to eql "---
servers:
  vpn-server-1:
    :type: :linux
    :data:
      :ip_address: 225.79.101.15
      :mode: dynamic
      :network: 10.8.0.0
      :username: root
      :password: test123
      :key_pem: \"/tmp/user.pem\"
      :installed: true
      :configured: true
      :file_conf: \"/tmp/server.conf\"
      :file_ca_crt: \"/tmp/ca.crt\"
      :file_pem: \"/tmp/server.pem\"
      :file_crt: \"/tmp/server.crt\"
      :file_key: \"/tmp/server.key\"
  aws-server-1:
    :type: :aws
    :data:
      :ip_address: 55.29.16.157
      :mode: :dynamic
      :network:#{' '}
      :username: ec2-user
      :password:#{' '}
      :key_pem: \"/tmp/ec2_test.pem\"
      :installed: true
      :configured: true
      :file_conf: \"/tmp/server.conf\"
      :file_ca_crt: \"/tmp/ca.crt\"
      :file_pem: \"/tmp/server.pem\"
      :file_crt: \"/tmp/server.crt\"
      :file_key: \"/tmp/server.key\"
      :region: us-west-2
      :zone: us-west-2a
      :access_key_id: AMAZONAWSEC2ACCESKEY
      :secret_key: AmazonAwsEC2SecretKey
      :ami: ami-12345678
      :instance_type: t2.micro
      :key_pair: aws_keypair_name
      :security_groups:
      - sg-12345678
      - sg-87654321
      :instance_id: i-12345678
      :vpc_id: vpc-87654321f
      :private_ip_address: 172.32.45.159
      :public_dns_name: ec2-55-19-16-157.us-west-2.compute.amazonaws.com
clients:
  vpn-client-10:
    :type: :linux
    :server: vpn-server-1
    :status: :new
    :error:#{' '}
    :data:
      :ip_address: 88.159.47.22
      :username: root
      :password: test123
      :key_pem:#{' '}
      :vpn_ip_address:#{' '}
      :generate_key:#{' '}
  vpn-client-99:
    :type: :linux
    :server: vpn-server-1
    :status: :new
    :error:#{' '}
    :data:
      :ip_address: 204.99.63.105
      :username: root
      :password:#{' '}
      :key_pem: \"/tmp/user.pem\"
      :vpn_ip_address:#{' '}
      :generate_key:#{' '}
  aws-client-01:
    :type: :linux
    :server: aws-server-1
    :status: :new
    :error:#{' '}
    :data:
      :ip_address: 188.59.47.122
      :username: root
      :password: test123
      :key_pem:#{' '}
      :vpn_ip_address:#{' '}
      :generate_key:#{' '}
  aws-client-02:
    :type: :linux
    :server: aws-server-1
    :status: :new
    :error:#{' '}
    :data:
      :ip_address: 214.93.163.15
      :username: root
      :password:#{' '}
      :key_pem: \"/tmp/user.pem\"
      :vpn_ip_address:#{' '}
      :generate_key:#{' '}
"
      end
    end # End context All

  end # End context Export

end
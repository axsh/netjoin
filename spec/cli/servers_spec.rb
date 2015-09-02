require 'spec_helper'

describe Netjoin::Cli::Servers do

  context "Show" do

    context "All" do
      let(:output) { capture(:stdout) { subject.show } }

      it "shows all servers" do
        expect(output).to eql "---
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
"
      end
    end # End context All

    context "Single" do
      let(:output) { capture(:stdout) {
        subject.options = {:name => 'vpn-server-1'}
        subject.show
      } }

      it "shows an existing server" do
        expect(output).to eql "---
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
"
      end
    end # End context Single

    context "Non-existing" do
      let(:output) { capture(:stdout) {
        subject.options = {:name => 'test-server2'}
        subject.show
      } }

      it "fails to show a non-existing server" do
        expect(output).to eql "ERROR : server with name 'test-server2' does not exist\n"
      end
    end # End context Non-existing

  end

  context "Delete" do

    context "Existing" do
      let(:output) { capture(:stdout) { subject.delete 'test-server' } }
      let(:output) { capture(:stdout) { subject.delete 'test-server-aws' } }

      it "deletes an existing server" do
        expect(output).to_not include '{:type=>:linux, :data=>{:ip_address=>"0.0.0.1", :username=>"root2", :password=>"root2"}}'
      end
    end # End context Existing

    context "Non-existing" do
      let(:output) { capture(:stdout) { subject.delete 'test-server' } }

      it "fails to delete a non-existing server" do
        expect(output).to eql "ERROR : server with name 'test-server' does not exist\n"
      end
    end # End context Non-existing

  end
end
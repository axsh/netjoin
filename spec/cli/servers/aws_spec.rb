require 'spec_helper'

describe Ducttape::Cli::Server::Aws do

  context "Show" do

    context "All" do
      let(:output) { capture(:stdout) { subject.show } }

      it "shows all aws servers" do
        expect(output).to eql "---
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
"
      end
    end # End context All

    context "Single" do
      let(:output) { capture(:stdout) {
        subject.options = {:name => 'aws-server-1'}
        subject.show
      } }

      it "show a single linux server" do
        expect(output).to include "---
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

  context "Add" do

    context "New" do
      let(:output) { capture(:stdout) {
        subject.options = {
          :access_key_id => 'AmazonAwsEc2AccessKeyId',
          :ami => 'ami-12345678',
          :configured => 'true',
          :file_ca_crt => '/tmp/ca.crt',
          :file_conf => '/tmp/server.conf',
          :file_crt => '/tmp/server.crt',
          :file_key => '/tmp/server.key',
          :file_pem => '/tmp/server.pem',
          :installed => 'true',
          :instance_type => 't2.micro',
          :key_pair => 'aws_keypair_name',
          :key_pem => '/tmp/amazon.pem',
          :password => 'password',
          :region => 'us-west-1',
          :secret_key => 'AmazonEwsEc2SectretKey',
          :security_groups => ['sg-12345678', 'sg-87654321'],
          :zone => 'us-west-1b',
        }
        subject.add 'test-server-aws'
      } }

      it "creates a new aws server" do
        expect(output).to eql "---
test-server-aws:
  :type: :aws
  :data:
    :ip_address:#{' '}
    :mode: :dynamic
    :network:#{' '}
    :username: ec2-user
    :password: password
    :key_pem: \"/tmp/amazon.pem\"
    :installed: true
    :configured: true
    :file_conf: \"/tmp/server.conf\"
    :file_ca_crt: \"/tmp/ca.crt\"
    :file_pem: \"/tmp/server.pem\"
    :file_crt: \"/tmp/server.crt\"
    :file_key: \"/tmp/server.key\"
    :region: us-west-1
    :zone: us-west-1b
    :access_key_id: AmazonAwsEc2AccessKeyId
    :secret_key: AmazonEwsEc2SectretKey
    :ami: ami-12345678
    :instance_type: t2.micro
    :key_pair: aws_keypair_name
    :security_groups:
    - sg-12345678
    - sg-87654321
    :instance_id:#{' '}
    :vpc_id:#{' '}
    :private_ip_address:#{' '}
    :public_dns_name:#{' '}
"
      end
    end # End context News

    context "Duplicate" do
      let(:output) { capture(:stdout) {
        subject.options = {
          :access_key_id => 'AmazonAwsEc2AccessKeyId',
          :ami => 'ami-12345678',
          :configured => 'true',
          :file_ca_crt => '/tmp/ca.crt',
          :file_conf => '/tmp/server.conf',
          :file_crt => '/tmp/server.crt',
          :file_key => '/tmp/server.key',
          :file_pem => '/tmp/server.pem',
          :installed => 'true',
          :instance_type => 't2.micro',
          :key_pair => 'key_pair_name',
          :key_pem => '/tmp/amazon.pem',
          :password => 'password',
          :region => 'us-west-1',
          :secret_key => 'AmazonEwsEc2SectretKey',
          :security_groups => ['sg-12345678', 'sg-87654321'],
          :zone => 'us-west-1b',
        }
        subject.add 'test-server-aws'
      } }

      it "fails to create an already existing server" do
        expect(output).to eql "ERROR : server with name 'test-server-aws' already exists\n"
      end
    end # End context Duplicate
  end # End context Add

  context "Update" do

    context "Existing" do
      let(:output) { capture(:stdout) {
        subject.options = {
          :access_key_id => 'AmazonAwsEc2AccessKeyId-2',
          :ami => 'ami-87654321',
          :configured => 'false',
          :file_ca_crt => '/tmp/ca-2.crt',
          :file_conf => '/tmp/server-2.conf',
          :file_crt => '/tmp/server-2.crt',
          :file_key => '/tmp/server-2.key',
          :file_pem => '/tmp/server-2.pem',
          :installed => 'false',
          :instance_type => 't2.mini',
          :key_pair => 'aws-keypair_name-2',
          :key_pem => '/tmp/amazon-2.pem',
          :password => 'password-2',
          :region => 'us-west-2',
          :secret_key => 'AmazonEwsEc2SectretKey-2',
          :security_groups => ['sg-12345678-2', 'sg-87654321-2'],
          :zone => 'us-west-2b',
        }
        subject.update 'test-server-aws'
      } }

      it "updates an existing server" do
        expect(output).to eql "---
test-server-aws:
  :type: :aws
  :data:
    :ip_address:#{' '}
    :mode: :dynamic
    :network:#{' '}
    :username: ec2-user
    :password: password-2
    :key_pem: \"/tmp/amazon-2.pem\"
    :installed: false
    :configured: false
    :file_conf: \"/tmp/server-2.conf\"
    :file_ca_crt: \"/tmp/ca-2.crt\"
    :file_pem: \"/tmp/server-2.pem\"
    :file_crt: \"/tmp/server-2.crt\"
    :file_key: \"/tmp/server-2.key\"
    :region: us-west-2
    :zone: us-west-2b
    :access_key_id: AmazonAwsEc2AccessKeyId-2
    :secret_key: AmazonEwsEc2SectretKey-2
    :ami: ami-87654321
    :instance_type: t2.mini
    :key_pair: aws-keypair_name-2
    :security_groups:
    - sg-12345678-2
    - sg-87654321-2
    :instance_id:#{' '}
    :vpc_id:#{' '}
    :private_ip_address:#{' '}
    :public_dns_name:#{' '}
"
      end
    end # End context Existing

    context "Non-existing" do
      let(:output) { capture(:stdout) {
        subject.options = {
          :access_key_id => 'AmazonAwsEc2AccessKeyId-2',
          :ami => 'ami-87654321',
          :configured => 'false',
          :file_ca_crt => '/tmp/ca-2.crt',
          :file_conf => '/tmp/server-2.conf',
          :file_crt => '/tmp/server-2.crt',
          :file_key => '/tmp/server-2.key',
          :file_pem => '/tmp/server-2.pem',
          :installed => 'false',
          :instance_type => 't2.mini',
          :key_pair => 'key_pair_name-2',
          :key_pem => '/tmp/amazon-2.pem',
          :password => 'password-2',
          :region => 'us-west-2',
          :secret_key => 'AmazonEwsEc2SectretKey-2',
          :security_groups => ['sg-12345678-2', 'sg-87654321-2'],
          :zone => 'us-west-2b',
        }
        subject.update 'test-server-aws2'
      } }

      it "fails to update a non-existing server" do
        expect(output).to eql "ERROR : server with name 'test-server-aws2' does not exist\n"
      end
    end # End context Non-existing
  end # End context Update

end
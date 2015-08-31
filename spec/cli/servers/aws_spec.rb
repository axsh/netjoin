require 'spec_helper'

describe Netjoin::Cli::Server::Aws do

  context "Show" do

    context "All" do
      let(:output) { capture(:stdout) { subject.show } }

      it "shows all aws servers" do
        expect(output).to eql "---
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
    :configured: true
    :file_ca_crt: \"/tmp/ca.crt\"
    :file_conf: \"/tmp/server.conf\"
    :file_crt: \"/tmp/server.crt\"
    :file_key: \"/tmp/server.key\"
    :file_pem: \"/tmp/server.pem\"
    :installed: true
    :ip_address:#{' '}
    :key_pem: \"/tmp/amazon.pem\"
    :mode: dynamic
    :network_ip:#{' '}
    :network_prefix:#{' '}
    :password: password
    :port:#{' '}
    :username: ec2-user
    :access_key_id: AmazonAwsEc2AccessKeyId
    :ami: ami-12345678
    :instance_id:#{' '}
    :instance_type: t2.micro
    :key_pair: aws_keypair_name
    :private_ip_address:#{' '}
    :public_dns_name:#{' '}
    :region: us-west-1
    :secret_key: AmazonEwsEc2SectretKey
    :security_groups:
    - sg-12345678
    - sg-87654321
    :vpc_id:#{' '}
    :zone: us-west-1b
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

# TODO find a way to make this test work
#    context "Missing required parameters" do
#      let(:output) { capture(:stdout) {
#        subject.add 'test-server-aws-params'
#      } }
#
#      it "show required parameters" do
#        expect(output).to eql "No value provided for required options '--access-key-id', '--ami', '--instance-type', '--key-pair', '--region', '--secret-key', '--security-groups', '--zone'\n"
#      end
#    end # End context Missing auth info


    context "Missing auth info" do
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
          :region => 'us-west-1',
          :secret_key => 'AmazonEwsEc2SectretKey',
          :security_groups => ['sg-12345678', 'sg-87654321'],
          :zone => 'us-west-1b',
        }
        subject.add 'test-server-aws-missing'
      } }

      it "show error message for missing auth information" do
        expect(output).to eql "ERROR : Missing a password or pem key file to ssh/scp\n"
      end
    end # End context Missing auth info

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
    :configured: false
    :file_ca_crt: \"/tmp/ca-2.crt\"
    :file_conf: \"/tmp/server-2.conf\"
    :file_crt: \"/tmp/server-2.crt\"
    :file_key: \"/tmp/server-2.key\"
    :file_pem: \"/tmp/server-2.pem\"
    :installed: false
    :ip_address:#{' '}
    :key_pem: \"/tmp/amazon-2.pem\"
    :mode: dynamic
    :network_ip:#{' '}
    :network_prefix:#{' '}
    :password: password-2
    :port:#{' '}
    :username: ec2-user
    :access_key_id: AmazonAwsEc2AccessKeyId-2
    :ami: ami-87654321
    :instance_id:#{' '}
    :instance_type: t2.mini
    :key_pair: aws-keypair_name-2
    :private_ip_address:#{' '}
    :public_dns_name:#{' '}
    :region: us-west-2
    :secret_key: AmazonEwsEc2SectretKey-2
    :security_groups:
    - sg-12345678-2
    - sg-87654321-2
    :vpc_id:#{' '}
    :zone: us-west-2b
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
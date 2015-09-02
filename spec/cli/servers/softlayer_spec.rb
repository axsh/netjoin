require 'spec_helper'

describe Netjoin::Cli::Server::Softlayer do

  context "Show" do

    context "All" do
      let(:output) { capture(:stdout) { subject.show } }

      it "shows all softlayer servers" do
        expect(output).to eql "---
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
        subject.options = {:name => 'softlayer-server-1'}
        subject.show
      } }

      it "show a single softlayer server" do
        expect(output).to include "---
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
          :file_ca_crt => "/tmp/ca.crt",
          :file_conf => "/tmp/server.conf",
          :file_crt => "/tmp/server.crt",
          :file_key => "/tmp/server.key",
          :file_pem => "/tmp/server.pem",
          :ip_address => '0.0.0.0',
          :mode => 'dynamic',
          :network_ip => '10.8.0.0',
          :network_prefix => 32,
          :port => 1500,
          :domain => 'example.com',
          :hostname => 'netjoin',
          :ssl_api_key => 'SoftLayerSSLAPIKey',
          :ssl_api_username => 'ssl_username'
        }
        subject.add 'test-server'
      } }

      it "creates a new softlayer server" do
        expect(output).to eql "---
test-server:
  :type: :softlayer
  :data:
    :configured:#{' '}
    :file_ca_crt: \"/tmp/ca.crt\"
    :file_conf: \"/tmp/server.conf\"
    :file_crt: \"/tmp/server.crt\"
    :file_key: \"/tmp/server.key\"
    :file_pem: \"/tmp/server.pem\"
    :installed:#{' '}
    :ip_address:#{' '}
    :key_pem:#{' '}
    :mode: dynamic
    :network_ip: 10.8.0.0
    :network_prefix: 32
    :password:#{' '}
    :port: 1500
    :username:#{' '}
    :domain: example.com
    :hostname: netjoin
    :instance_id:#{' '}
    :ssl_api_key: SoftLayerSSLAPIKey
    :ssl_api_username: ssl_username
"
      end
    end # End context News

    context "Duplicate" do
      let(:output) { capture(:stdout) {
        subject.options = {
          :file_ca_crt => "/tmp/ca.crt",
          :file_conf => "/tmp/server.conf",
          :file_crt => "/tmp/server.crt",
          :file_key => "/tmp/server.key",
          :file_pem => "/tmp/server.pem",
          :ip_address => '0.0.0.0',
          :mode => 'dynamic',
          :network_ip => '10.8.0.0',
          :network_prefix => 32,
          :port => 1500,
          :domain => 'example.com',
          :hostname => 'netjoin',
          :ssl_api_key => 'SoftLayerSSLAPIKey',
          :ssl_api_username => 'ssl_username'
        }
        subject.add 'test-server'
      } }

      it "fails to create an already existing server" do
        expect(output).to eql "ERROR : server with name 'test-server' already exists\n"
      end
    end # End context Duplicate

# TODO find a way to make this test work
#    context "Missing parameters" do
#      let(:output) { capture(:stdout) {
#        subject.options = {
#          :ip_address => '',
#          :username => '',
#        }
#        subject.add 'test-server-param'
#      } }
#
#      it "Shows required parameters" do
#        expect(output).to eql "No value provided for required options '--ip-address', '--username'\n"
#      end
#    end # End context Missing parameters

    context "Invalid IP Address" do
      let(:output) { capture(:stdout) {
        subject.options = {
          :file_ca_crt => "/tmp/ca.crt",
          :file_conf => "/tmp/server.conf",
          :file_crt => "/tmp/server.crt",
          :file_key => "/tmp/server.key",
          :file_pem => "/tmp/server.pem",
          :ip_address => '0.0.0.300',
          :mode => 'dynamic',
          :network_ip => '10.8.0.0',
          :network_prefix => 32,
          :port => 1500,
          :domain => 'example.com',
          :hostname => 'netjoin',
          :ssl_api_key => 'SoftLayerSSLAPIKey',
          :ssl_api_username => 'ssl_username'
        }
        subject.add 'test-server-2'
      } }

      it "show error message for invalid IP address" do
        expect(output).to eql "ERROR : Not a valid IP address!\n"
      end
    end # End context Invalid IP Address

    context "Invalid network IP Address" do
      let(:output) { capture(:stdout) {
        subject.options = {
          :file_ca_crt => "/tmp/ca.crt",
          :file_conf => "/tmp/server.conf",
          :file_crt => "/tmp/server.crt",
          :file_key => "/tmp/server.key",
          :file_pem => "/tmp/server.pem",
          :ip_address => '0.0.0.0',
          :mode => 'dynamic',
          :network_ip => '10.308.0.0',
          :network_prefix => 32,
          :port => 1500,
          :domain => 'example.com',
          :hostname => 'netjoin',
          :ssl_api_key => 'SoftLayerSSLAPIKey',
          :ssl_api_username => 'ssl_username'
        }
        subject.add 'test-server-2'
      } }

      it "show error message for invalid network IP address" do
        expect(output).to eql "ERROR : Not a valid network IP address!\n"
      end
    end # End context Invalid network IP Address

  end # End context Add

  context "Update" do

    context "Existing" do
      let(:output) { capture(:stdout) {
        subject.options = {
          :file_ca_crt => "/tmp/ca-2.crt",
          :file_conf => "/tmp/server-2.conf",
          :file_crt => "/tmp/server-2.crt",
          :file_key => "/tmp/server-2.key",
          :file_pem => "/tmp/server-2.pem",
          :ip_address => '0.0.0.1',
          :mode => 'static',
          :network_ip => '10.9.0.0',
          :network_prefix => 24,
          :password => 'root2',
          :port => 1600,
          :username => 'root2',
          :domain => 'example2.net',
          :hostname => 'net-join',
          :ssl_api_key => 'SoftLayerSSLAPIKeyNumber2',
          :ssl_api_username => 'ssl_username_2'
        }
        subject.update 'test-server'
      } }

      it "updates an existing server" do
        expect(output).to eql "---
test-server:
  :type: :softlayer
  :data:
    :configured:#{' '}
    :file_ca_crt: \"/tmp/ca-2.crt\"
    :file_conf: \"/tmp/server-2.conf\"
    :file_crt: \"/tmp/server-2.crt\"
    :file_key: \"/tmp/server-2.key\"
    :file_pem: \"/tmp/server-2.pem\"
    :installed:#{' '}
    :ip_address: 0.0.0.1
    :key_pem:#{' '}
    :mode: static
    :network_ip: 10.9.0.0
    :network_prefix: 24
    :password: root2
    :port: 1600
    :username: root2
    :domain: example2.net
    :hostname: net-join
    :instance_id:#{' '}
    :ssl_api_key: SoftLayerSSLAPIKeyNumber2
    :ssl_api_username: ssl_username_2
"
      end
    end # End context Existing

    context "Non-existing" do
      let(:output) { capture(:stdout) {
        subject.options = {:ip_address => '0.0.0.1', :username => 'root2', :password => 'root2'}
        subject.update 'test-server2'
      } }

      it "fails to update a non-existing server" do
        expect(output).to eql "ERROR : server with name 'test-server2' does not exist\n"
      end
    end # End context Non-existing

    context "Invalid IP Address" do
      let(:output) { capture(:stdout) {
        subject.options = {
          :ip_address => '0.0.0.300',
        }
        subject.update 'test-server'
      } }

      it "show error message for invalid IP address" do
        expect(output).to eql "ERROR : Not a valid IP address!\n"
      end
    end # End context Invalid IP Address

    context "Invalid network IP Address" do
      let(:output) { capture(:stdout) {
        subject.options = {
          :network_ip => '10.300.0.0',
        }
        subject.update 'test-server'
      } }

      it "show error message for invalid network IP address" do
        expect(output).to eql "ERROR : Not a valid network IP address!\n"
      end
    end # End context Invalid IP Address

  end # End context Update

end
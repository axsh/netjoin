require 'spec_helper'

describe Netjoin::Cli::Server::Linux do

  context "Show" do

    context "All" do
      let(:output) { capture(:stdout) { subject.show } }

      it "shows all linux servers" do
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
"
      end
    end # End context All

    context "Single" do
      let(:output) { capture(:stdout) {
        subject.options = {:name => 'vpn-server-1'}
        subject.show
      } }

      it "show a single linux server" do
        expect(output).to include "---
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
          :password => 'root',
          :port => 1500,
          :username => 'root',
        }
        subject.add 'test-server'
      } }

      it "creates a new linux server" do
        expect(output).to eql "---
test-server:
  :type: :linux
  :data:
    :configured:#{' '}
    :file_ca_crt: \"/tmp/ca.crt\"
    :file_conf: \"/tmp/server.conf\"
    :file_crt: \"/tmp/server.crt\"
    :file_key: \"/tmp/server.key\"
    :file_pem: \"/tmp/server.pem\"
    :installed:#{' '}
    :ip_address: 0.0.0.0
    :key_pem:#{' '}
    :mode: dynamic
    :network_ip: 10.8.0.0
    :network_prefix: 32
    :password: root
    :port: 1500
    :username: root
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
          :password => 'root',
          :username => 'root',
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

    context "Missing auth info" do
      let(:output) { capture(:stdout) {
        subject.options = {
          :file_ca_crt => "/tmp/ca.crt",
          :file_conf => "/tmp/server.conf",
          :file_crt => "/tmp/server.crt",
          :file_key => "/tmp/server.key",
          :ip_address => '0.0.0.0',
          :mode => 'dynamic',
          :network_ip => '10.8.0.0',
          :network_prefix => 32,
          :username => 'root',
        }
        subject.add 'test-server-missing'
      } }

      it "show error message for missing auth information" do
        expect(output).to eql "ERROR : Missing a password or pem key file to ssh/scp\n"
      end
    end # End context Missing auth info

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
          :password => 'root',
          :username => 'root',
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
          :password => 'root',
          :username => 'root',
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
        }
        subject.update 'test-server'
      } }

      it "updates an existing server" do
        expect(output).to eql "---
test-server:
  :type: :linux
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

    context "Missing auth info" do
      let(:output) { capture(:stdout) {
        subject.options = {
          :password => '',
          :file_key => '',
        }
        subject.update 'test-server'
      } }

      it "show error message for missing auth information" do
        expect(output).to eql "ERROR : Missing a password or pem key file to ssh/scp\n"
      end
    end # End context Missing auth info

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
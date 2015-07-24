require 'spec_helper'

describe Ducttape::Cli::Server::Linux do

  context "Show" do

    context "All" do
      let(:output) { capture(:stdout) { subject.show } }

      it "shows all linux servers" do
        expect(output).to eql "---
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
    :file_pem: \"/tmp/dh2048.pem\"
    :file_crt: \"/tmp/server.crt\"
    :file_key: \"/tmp/server.key\"
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
  :file_pem: \"/tmp/dh2048.pem\"
  :file_crt: \"/tmp/server.crt\"
  :file_key: \"/tmp/server.key\"
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
        subject.options = {:ip_address => '0.0.0.0', :username => 'root', :password => 'root', :mode => 'dynamic', :network => '10.8.0.0',
            :file_conf => "/tmp/server.conf", :file_ca_crt => "/tmp/ca.crt", :file_pem => "/tmp/dh2048.pem", :file_crt => "/tmp/server.crt", :file_key => "/tmp/server.key"
        }
        subject.add 'test-server'
      } }

      it "creates a new linux server" do
        expect(output).to eql "---
test-server:
  :type: :linux
  :data:
    :ip_address: 0.0.0.0
    :mode: dynamic
    :network: 10.8.0.0
    :username: root
    :password: root
    :key_pem:#{' '}
    :installed:#{' '}
    :configured:#{' '}
    :file_conf: \"/tmp/server.conf\"
    :file_ca_crt: \"/tmp/ca.crt\"
    :file_pem: \"/tmp/dh2048.pem\"
    :file_crt: \"/tmp/server.crt\"
    :file_key: \"/tmp/server.key\"
"
      end
    end # End context News

    context "Duplicate" do
      let(:output) { capture(:stdout) {
        subject.options = {:ip_address => '0.0.0.0', :username => 'root', :password => 'root'}
        subject.add 'test-server'
      } }

      it "fails to create an already existing server" do
        expect(output).to eql "ERROR : server with name 'test-server' already exists\n"
      end
    end # End context Duplicate
  end # End context Add

  context "Update" do

    context "Existing" do
      let(:output) { capture(:stdout) {
        subject.options = {:ip_address => '0.0.0.1', :username => 'root2', :password => 'root2', :mode => 'static', :network => '10.9.0.0',
            :file_conf => "/tmp/server-2.conf", :file_ca_crt => "/tmp/ca-2.crt", :file_pem => "/tmp/dh2048-2.pem", :file_crt => "/tmp/server-2.crt", :file_key => "/tmp/server-2.key"
        }
        subject.update 'test-server'
      } }

      it "updates an existing server" do
        expect(output).to eql "---
test-server:
  :type: :linux
  :data:
    :ip_address: 0.0.0.1
    :mode: static
    :network: 10.9.0.0
    :username: root2
    :password: root2
    :key_pem:#{' '}
    :installed:#{' '}
    :configured:#{' '}
    :file_conf: \"/tmp/server-2.conf\"
    :file_ca_crt: \"/tmp/ca-2.crt\"
    :file_pem: \"/tmp/dh2048-2.pem\"
    :file_crt: \"/tmp/server-2.crt\"
    :file_key: \"/tmp/server-2.key\"
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
  end # End context Update

end
require 'spec_helper'

describe Ducttape::Cli::Client::Linux do

  context "Show" do

    context "All" do
      let(:output) { capture(:stdout) { subject.show } }

      it "shows all linux clients" do
        expect(output).to eql "---
vpn-client-10:
  :type: :linux
  :server: vpn-server-1
  :status: :new
  :error:#{' '}
  :data:
    :generate_key:#{' '}
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
    :generate_key:#{' '}
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
    :generate_key:#{' '}
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
    :generate_key:#{' '}
    :ip_address: 214.93.163.15
    :key_pem: \"/tmp/user.pem\"
    :password:#{' '}
    :username: root
    :vpn_ip_address:#{' '}
"
      end
    end # End context All

    context "Single" do
      let(:output) { capture(:stdout) {
        subject.options = {:name => 'vpn-client-10'}
        subject.show
      } }

      it "show a single linux client" do
        expect(output).to eql "---
:type: :linux
:server: vpn-server-1
:status: :new
:error:#{' '}
:data:
  :generate_key:#{' '}
  :ip_address: 88.159.47.22
  :key_pem:#{' '}
  :password: test123
  :username: root
  :vpn_ip_address:#{' '}
"
      end
    end # End context Single

    context "Non-existing" do
      let(:output) { capture(:stdout) {
        subject.options = {:name => 'test-client2'}
        subject.show
      } }

      it "fails to show a non-existing client" do
        expect(output).to eql "ERROR : client with name 'test-client2' does not exist\n"
      end
    end # End context Non-existing
  end # End context Show

  context "Add" do
    context "New" do
      let(:output) { capture(:stdout) {
        subject.options = {
          :generate_key => "true",
          :ip_address => '0.0.0.0',
          :key_pem => '/tmp/user.pem',
          :password => 'test-value',
          :server => 'test-server',
          :username => 'test-value',
          :vpn_ip_address => "10.8.0.50",
        }
        subject.add 'test-client'
      } }

      it "creates a new linux client" do
        expect(output).to eql "---
test-client:
  :type: :linux
  :server: test-server
  :status: :new
  :error:#{' '}
  :data:
    :generate_key: 'true'
    :ip_address: 0.0.0.0
    :key_pem: \"/tmp/user.pem\"
    :password: test-value
    :username: test-value
    :vpn_ip_address: 10.8.0.50
"
      end
    end # End context new

    context "Duplicate" do
      let(:output) { capture(:stdout) {
        subject.options = {:ip_address => '0.0.0.0', :username => 'test-value', :server => 'new-server', :password => 'test-value'}
        subject.add 'test-client'
      } }

      it "fails to create an already existing client" do
        expect(output).to eql "ERROR : client with name 'test-client' already exists\n"
      end
    end # End context Duplicate

  end # End context Add

  context "Update" do

    context "Existing" do
      let(:output) { capture(:stdout) {
        subject.options = {:server => 'test-server2', :ip_address => '0.0.0.1', :username => 'test-value2', :password => 'test-value2', :key_pem => '/tmp/user2.pem', :vpn_ip_address => "10.8.0.52", :generate_key => "false"}
        subject.update 'test-client'
      } }

      it "updates an existing client" do
        expect(output).to eql "---
test-client:
  :type: :linux
  :server: test-server2
  :status: :new
  :error:#{' '}
  :data:
    :generate_key: 'false'
    :ip_address: 0.0.0.1
    :key_pem: \"/tmp/user2.pem\"
    :password: test-value2
    :username: test-value2
    :vpn_ip_address: 10.8.0.52
"
      end
    end # end context Existing

    context "Non-existing" do
      let(:output) { capture(:stdout) {
        subject.options = {:ip_address => '0.0.0.1', :username => 'test-value2', :password => 'test-value2'}
        subject.update 'test-client2'
      } }

      it "fails to update a non-existing client" do
        expect(output).to eql "ERROR : client with name 'test-client2' does not exist\n"
      end
    end # End context Non-existing

  end # End context Update

end

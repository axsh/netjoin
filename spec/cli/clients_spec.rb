require 'spec_helper'

describe Netjoin::Cli::Clients do

  context "Show" do

    context "All" do
      let(:output) { capture(:stdout) { subject.show } }

      it "show all the clients" do
        expect(output).to eql "---
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
    end # End context "All"

    context "Single" do
      let(:output) { capture(:stdout) {
        subject.options = {:name => 'vpn-client-10'}
        subject.show
      } }

      it "show an existing client" do
        expect(output).to eql "---
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

  context "Status" do

    context "All" do
      let(:output) { capture(:stdout) {
        subject.status
      } }

      it "show status of all client" do
        expect(output).to eql "\"vpn-client-10\" : new
\"vpn-client-99\" : new
\"aws-client-01\" : new
\"aws-client-02\" : new
\"softlayer-client-01\" : new
"
      end
    end # End context All

    context "Single" do
      let(:output) { capture(:stdout) {
        subject.options = {:name => 'vpn-client-10'}
        subject.status
      } }

      it "show status of a single client" do
        expect(output).to eql "new\n"
      end
    end # End context Single

  end # end context Status

  context "Delete" do

    context "Single" do
      let(:output) { capture(:stdout) { subject.delete 'test-client' } }

      it "deletes an existing client" do
        expect(output).not_to include "---
test-client:
  :type: :linux
  :server: test-server
  :status: :new
  :error:#{' '}
  :data:
    :generate_key:#{' '}
    :file_key:#{' '}
    :ip_address: 0.0.0.1
    :key_pem:#{' '}
    :password: test-value2
    :username: test-value2
    :vpn_ip_address:#{' '}
"
      end
    end # End context Single

    context "Non-existing" do
      let(:output) { capture(:stdout) { subject.delete 'test-client' } }

      it "fails to delete a non-existing client" do
        expect(output).to eql "ERROR : client with name 'test-client' does not exist\n"
      end
    end # End context Non-existing

  end # End context Delete
end
require 'spec_helper'

describe Ducttape::Cli::Clients do

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
    :ip_address: 88.159.47.22
    :username: root
    :password: test123
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
    :password: test123
    :vpn_ip_address:#{' '}
    :generate_key:#{' '}
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
  :ip_address: 88.159.47.22
  :username: root
  :password: test123
  :vpn_ip_address:#{' '}
  :generate_key:#{' '}
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
        expect(output).to eql "\"vpn-client-10\" : new\n\"vpn-client-99\" : new\n"
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
    :ip_address: 0.0.0.1
    :username: test-value2
    :password: test-value2
    :vpn_ip_address:#{' '}
    :generate_key:#{' '}
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
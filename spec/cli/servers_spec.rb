require 'spec_helper'

describe Ducttape::Cli::Servers do

  context "Show" do

    context "All" do
      let(:output) { capture(:stdout) { subject.show } }

      it "shows all servers" do
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

      it "shows an existing server" do
        expect(output).to eql "---
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

  context "Delete" do

    context "Existing" do
      let(:output) { capture(:stdout) { subject.delete 'test-server' } }

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
require 'spec_helper'

describe Netjoin::Cli::Client::Linux do

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

  context "Add" do
    context "New" do
      let(:output) { capture(:stdout) {
        subject.options = {
          :generate_key => "true",
          :file_key => "/tmp/client.ovpn",
          :ip_address => '0.0.0.0',
          :key_pem => '/tmp/user.pem',
          :password => 'test-value',
          :server => 'vpn-server-1',
          :username => 'test-value',
          :vpn_ip_address => "10.8.0.50",
        }
        subject.add 'test-client'
      } }

      it "creates a new linux client" do
        expect(output).to eql "---
test-client:
  :type: :linux
  :server: vpn-server-1
  :status: :new
  :error:#{' '}
  :data:
    :generate_key: true
    :file_key: \"/tmp/client.ovpn\"
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
        subject.options = {
          :generate_key => "true",
          :file_key => "/tmp/client.ovpn",
          :ip_address => '0.0.0.0',
          :key_pem => '/tmp/user.pem',
          :password => 'test-value',
          :server => 'vpn-server-1',
          :username => 'test-value',
          :vpn_ip_address => "10.8.0.50",
        }
        subject.add 'test-client'
      } }

      it "fails to create an already existing client" do
        expect(output).to eql "ERROR : client with name 'test-client' already exists\n"
      end
    end # End context Duplicate

# TODO find a way to make this test work
#    context "Missing parameters" do
#      let(:output) { capture(:stdout) {
#        subject.options = {
#          :ip_address => '',
#          :server => '',
#          :username => '',
#      }
#        subject.add 'test-client-param'
#      } }
#
#      it "show the missing required parameters" do
#        expect(output).to eql "No value provided for required options '--ip-address', '--server', '--username'\n"
#      end
#    end # End context Missing paramters

    context "Missing auth info" do
      let(:output) { capture(:stdout) {
        subject.options = {
          :generate_key => true,
          :ip_address => '0.0.0.0',
          :server => 'vpn-server-1',
          :username => 'test-value',
          :vpn_ip_address => "10.8.0.50",
        }
        subject.add 'test-client-missing'
      } }

      it "show error message for missing auth information" do
        expect(output).to eql "ERROR : Missing a password or pem key file to ssh/scp\n"
      end
    end # End context Missing auth info

    context "Missing certificate info" do
      let(:output) { capture(:stdout) {
        subject.options = {
          :ip_address => '0.0.0.0',
          :password => "test",
          :server => 'vpn-server-1',
          :username => 'test-value',
          :vpn_ip_address => "10.8.0.50",
        }
        subject.add 'test-client-cert'
      } }

      it "show error message for missing certificate information" do
        expect(output).to eql "ERROR : Key file missing, if you want to generate a key file, add '--generate true' to the command.
        This will only work if the OpenVPN Server has easy-rsa installed and configures!\n"
      end
    end # End context Missing certificate

    context "Server does not exist" do
      let(:output) { capture(:stdout) {
        subject.options = {
          :generate_key => "true",
          :file_key => "/tmp/client.ovpn",
          :ip_address => '0.0.0.0',
          :key_pem => '/tmp/user.pem',
          :password => 'test-value',
          :server => 'non-existing',
          :username => 'test-value',
          :vpn_ip_address => "10.8.0.50",
        }
        subject.add 'test-client-server'
      } }
      it "show an error" do
        expect(output).to eql "ERROR : Server does not exist!\n"
      end
    end

    context "Invalid IP Address" do
      let(:output) { capture(:stdout) {
        subject.options = {
          :generate_key => "true",
          :file_key => "/tmp/client.ovpn",
          :ip_address => '0.0.0.300',
          :key_pem => '/tmp/user.pem',
          :password => 'test-value',
          :server => 'vpn-server-1',
          :username => 'test-value',
          :vpn_ip_address => "10.8.0.50",
        }
        subject.add 'test-client-2'
      } }

      it "show an error" do
        expect(output).to eql "ERROR : Not a valid IP address!\n"
      end
    end # End context Invalid IP Address

    context "Invalid VPN IP Address" do
      let(:output) { capture(:stdout) {
        subject.options = {
          :generate_key => "true",
          :file_key => "/tmp/client.ovpn",
          :ip_address => '0.0.0.0',
          :key_pem => '/tmp/user.pem',
          :password => 'test-value',
          :server => 'vpn-server-1',
          :username => 'test-value',
          :vpn_ip_address => "10.8.0.350",
        }
        subject.add 'test-client-2'
      } }

      it "show an error" do
        expect(output).to eql "ERROR : Not a valid VPN IP address!\n"
      end
    end # End context Invalid VPN IP Address

  end # End context Add

  context "Update" do

    context "Existing" do
      let(:output) { capture(:stdout) {
        subject.options = {
          :generate_key => "false",
          :file_key => "/tmp/client-2.ovpn",
          :key_pem => '/tmp/user2.pem',
          :ip_address => '0.0.0.1',
          :password => 'test-value2',
          :server => 'aws-server-1',
          :username => 'test-value2',
          :vpn_ip_address => "10.8.0.52",
        }
        subject.update 'test-client'
      } }

      it "updates an existing client" do
        expect(output).to eql "---
test-client:
  :type: :linux
  :server: aws-server-1
  :status: :new
  :error:#{' '}
  :data:
    :generate_key: false
    :file_key: \"/tmp/client-2.ovpn\"
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
        subject.options = {
          :ip_address => '0.0.0.1',
          :password => 'test-value2',
          :username => 'test-value2',
        }
        subject.update 'test-client2'
      } }

      it "fails to update a non-existing client" do
        expect(output).to eql "ERROR : client with name 'test-client2' does not exist\n"
      end
    end # End context Non-existing

    context "Missing auth info" do
      let(:output) { capture(:stdout) {
        subject.options = {
          :key_pem => '',
          :password => '',
        }
        subject.update 'test-client'
      } }

      it "show error message for missing auth information" do
        expect(output).to eql "ERROR : Missing a password or pem key file to ssh/scp\n"
      end
    end # End context Missing auth info

    context "Missing certificate info" do
      let(:output) { capture(:stdout) {
        subject.options = {
          :ip_address => '',
          :file_key => '',
        }
        subject.update 'test-client'
      } }

      it "show error message for missing certificate information" do
        expect(output).to eql "ERROR : Key file missing, if you want to generate a key file, add '--generate true' to the command.
        This will only work if the OpenVPN Server has easy-rsa installed and configures!\n"
      end
    end # End context Missing certificate

    context "Server does not exist" do
      let(:output) { capture(:stdout) {
        subject.options = {
          :server => 'non-existing',
        }
        subject.update 'test-client'
      } }
      it "show an error" do
        expect(output).to eql "ERROR : Server does not exist!\n"
      end
    end

    context "Invalid IP Address" do
      let(:output) { capture(:stdout) {
        subject.options = {
          :ip_address => '0.0.0.300',
        }
        subject.update 'test-client'
      } }

      it "show an error" do
        expect(output).to eql "ERROR : Not a valid IP address!\n"
      end
    end # End context Invalid IP Address

    context "Invalid VPN IP Address" do
      let(:output) { capture(:stdout) {
        subject.options = {
          :vpn_ip_address => "10.8.0.350",
        }
        subject.update 'test-client'
      } }

      it "show an error" do
        expect(output).to eql "ERROR : Not a valid VPN IP address!\n"
      end
    end # End context Invalid VPN IP Address

  end # End context Update

end

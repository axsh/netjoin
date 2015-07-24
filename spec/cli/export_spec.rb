require 'spec_helper'

describe Ducttape::Cli::Root do

  context "Export" do

    context "All" do
      let(:output) { capture(:stdout) { subject.export } }

      it "contains all the database content" do
        expect(output).to eql "---
servers:
  vpn-server-1:
    :type: :linux
    :data:
      :ip_address: 225.79.101.15
      :mode: dynamic
      :network: 10.8.0.0
      :username: root
      :password: test123
      :key_pem:#{' '}
      :installed: true
      :configured: true
      :file_conf: \"/tmp/server.conf\"
      :file_ca_crt: \"/tmp/ca.crt\"
      :file_pem: \"/tmp/dh2048.pem\"
      :file_crt: \"/tmp/server.crt\"
      :file_key: \"/tmp/server.key\"
clients:
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
    end # End context All

  end # End context Export

end
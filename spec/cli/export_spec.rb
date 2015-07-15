require 'spec_helper'

describe DucttapeCLI::CLI do

  context "Export" do

    context "All" do
      let(:output) { capture(:stdout) { subject.export } }

      it "contains all the database content" do
        expect(output).to eql '---
servers:
  vpn-server-1:
    :type: :linux
    :data:
      :ip_address: 225.79.101.15
      :username: root
      :password: test123
clients:
  vpn-client-10:
    :type: :linux
    :server: vpn-server
    :status: :new
    :error: 
    :data:
      :ip_address: 88.159.47.22
      :username: root
      :password: test123
  vpn-client-99:
    :type: :linux
    :server: vpn-server-1
    :status: :new
    :error: 
    :data:
      :ip_address: 204.99.63.105
      :username: root
      :password: test123
'
      end
    end # End context All

  end # End context Export

end
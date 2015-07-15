require 'spec_helper'

describe DucttapeCLI::Servers do

  context "Show" do

    context "All" do
      let(:output) { capture(:stdout) { subject.show } }

      it "contains server" do
        expect(output).to eql '---
vpn-server-1:
  :type: :linux
  :data:
    :ip_address: 225.79.101.15
    :username: root
    :password: test123
'          
      end
    end # End context All

    context "Single" do
      let(:output) { capture(:stdout) {
        subject.options = {:name => 'vpn-server-1'}
        subject.show
      } }

      it "contains server" do
        expect(output).to eql '---
:type: :linux
:data:
  :ip_address: 225.79.101.15
  :username: root
  :password: test123
'
      end
    end # End context Single

    context "Non-existing" do
      let(:output) { capture(:stdout) {
        subject.options = {:name => 'test-server2'}
        subject.show
      } }

      it "does not contain server" do
        expect(output).to eql "ERROR : server with name 'test-server2' does not exist\n"
      end
    end # End context Non-existing
    
  end
  
  context "Delete" do

    context "Existing" do
      let(:output) { capture(:stdout) { subject.delete 'test-server' } }

      it "does not contain server" do
        expect(output).to_not include '{:type=>:linux, :data=>{:ip_address=>"0.0.0.1", :username=>"root2", :password=>"root2"}}'          
      end
    end # End context Existing

    context "Non-existing" do
      let(:output) { capture(:stdout) { subject.delete 'test-server' } }

      it "does not contain server" do
        expect(output).to eql "ERROR : server with name 'test-server' does not exist\n"
      end
    end # End context Non-existing

  end
end
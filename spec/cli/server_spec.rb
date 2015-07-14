require 'spec_helper'

describe DucttapeCLI::Servers do

  describe "Database manipulation" do
    context "Linux" do

      subject(:linux) { DucttapeCLI::Server::Linux.new }
              
      context "Add" do
        
        
        let(:output) { capture(:stdout) { 
          subject.options = {:ip_address => '0.0.0.0', :username => 'root', :password => 'root'}
          subject.add 'test-server' 
        } }
          
        it "contains server" do
          expect(output).to eql '---
test-server:
  :type: :linux
  :data:
    :ip_address: 0.0.0.0
    :username: root
    :password: root
'
        end
      end
      
    end
    
    subject(:servers) { DucttapeCLI::Servers.new }
      
    context "Show" do  
      
      let(:output) { capture(:stdout) { subject.show } }
      
      it "contains server" do
        expect(output).to include 'test-server'          
      end
    end
  end
end
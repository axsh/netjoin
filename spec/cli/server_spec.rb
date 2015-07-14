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
      
      context "Add" do
              
        let(:output) { capture(:stdout) { 
          subject.options = {:ip_address => '0.0.0.1', :username => 'root2', :password => 'root2'}
          subject.update 'test-server' 
        } }
          
        it "contains server" do
          expect(output).to eql '---
test-server:
  :type: :linux
  :data:
    :ip_address: 0.0.0.1
    :username: root2
    :password: root2
'
        end
      end
      
    end
    
    subject(:servers) { DucttapeCLI::Servers.new }
      
    context "Show all" do  
      
      let(:output) { capture(:stdout) { subject.show } }
      
      it "contains server" do
        expect(output).to include '{:type=>:linux, :data=>{:ip_address=>"0.0.0.1", :username=>"root2", :password=>"root2"}}'          
      end
    end
    
    context "Show single" do  
          
      let(:output) { capture(:stdout) {
        subject.options = {:name => 'test-server'}
        subject.show 
      } }
      
      it "contains server" do
        expect(output).to include '{:type=>:linux, :data=>{:ip_address=>"0.0.0.1", :username=>"root2", :password=>"root2"}}'          
      end
    end
        
    context "Delete" do  
          
      let(:output) { capture(:stdout) { subject.delete 'test-server' } }
      
      it "contains server" do
        expect(output).to_not include '{:type=>:linux, :data=>{:ip_address=>"0.0.0.1", :username=>"root2", :password=>"root2"}}'          
      end
    end
  end
end
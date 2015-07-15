require 'spec_helper'

describe DucttapeCLI::Clients do
    
  context "Linux" do

    subject(:linux) { DucttapeCLI::Client::Linux.new }

    context "Add" do
      context "New" do
        let(:output) { capture(:stdout) {
          subject.options = {:server => 'test-server', :ip_address => '0.0.0.0', :username => 'test-value', :password => 'test-value'}
          subject.add 'test-client'
        } }

        it "contains client" do
          expect(output).to eql '---
test-client:
  :type: :linux
  :server: test-server
  :status: :new
  :error: 
  :data:
    :ip_address: 0.0.0.0
    :username: test-value
    :password: test-value
'
        end
      end # End context new

      context "Duplicate" do
        let(:output) { capture(:stdout) {
          subject.options = {:ip_address => '0.0.0.0', :username => 'test-value', :password => 'test-value'}
          subject.add 'test-client'
        } }

        it "already contains client" do
          expect(output).to eql "ERROR : client with name 'test-client' already exists\n"
        end
      end # End context Duplicate
      
    end # End context Add 

    context "Update" do
      
      context "Existing" do
        let(:output) { capture(:stdout) {
          subject.options = {:ip_address => '0.0.0.1', :username => 'test-value2', :password => 'test-value2'}
          subject.update 'test-client'
        } }

        it "contains client" do
          expect(output).to eql '---
test-client:
  :type: :linux
  :server: test-server
  :status: :new
  :error: 
  :data:
    :ip_address: 0.0.0.1
    :username: test-value2
    :password: test-value2
'
        end
      end # end context Existing

      context "Non-existing" do
        let(:output) { capture(:stdout) {
          subject.options = {:ip_address => '0.0.0.1', :username => 'test-value2', :password => 'test-value2'}
          subject.update 'test-client2'
        } }

        it "dot not contain client" do
          expect(output).to eql "ERROR : client with name 'test-client2' does not exist\n"
        end
      end # End context Non-existing
      
    end # End context Update

    context "Show all" do
      let(:output) { capture(:stdout) { subject.show } }

      it "contains client" do
        expect(output).to eql '---
test-client:
  :type: :linux
  :server: test-server
  :status: :new
  :error: 
  :data:
    :ip_address: 0.0.0.1
    :username: test-value2
    :password: test-value2
'
      end
    end

    context "Show single" do
      let(:output) { capture(:stdout) {
        subject.options = {:name => 'test-client'}
        subject.show
      } }

      it "contains client" do
        expect(output).to eql '---
:type: :linux
:server: test-server
:status: :new
:error: 
:data:
  :ip_address: 0.0.0.1
  :username: test-value2
  :password: test-value2
'
      end
    end

    context "Show single non-existing" do
      let(:output) { capture(:stdout) {
        subject.options = {:name => 'test-client2'}
        subject.show
      } }

      it "does not contain client" do
        expect(output).to eql "ERROR : client with name 'test-client2' does not exist\n"
      end
    end

  end
  
  context "Show" do

    subject(:clients) { DucttapeCLI::Clients.new }

    context "All" do
      let(:output) { capture(:stdout) { subject.show } }

      it "contains client" do
        expect(output).to eql '---
test-client:
  :type: :linux
  :server: test-server
  :status: :new
  :error: 
  :data:
    :ip_address: 0.0.0.1
    :username: test-value2
    :password: test-value2
'     
      end
    end # End context "All"

    context "Single" do
      let(:output) { capture(:stdout) {
        subject.options = {:name => 'test-client'}
        subject.show
      } }

      it "contains client" do
        expect(output).to eql '---
:type: :linux
:server: test-server
:status: :new
:error: 
:data:
  :ip_address: 0.0.0.1
  :username: test-value2
  :password: test-value2
'
      end
    end # End context Single
  
    context "Non-existing" do
      let(:output) { capture(:stdout) {
        subject.options = {:name => 'test-client2'}
        subject.show
      } }

      it "does not contain client" do
        expect(output).to eql "ERROR : client with name 'test-client2' does not exist\n"
      end
    end # End context Non-existing
  
  end # End context Show  
  
  context "Status" do
  
    context "All" do
      let(:output) { capture(:stdout) {
        subject.status
      } }

      it "does not contain client" do
        expect(output).to eql "\"test-client\" : new\n"
      end
    end # End context All
    
    context "Single" do
      let(:output) { capture(:stdout) {
        subject.options = {:name => 'test-client'}
        subject.status
      } }

      it "does not contain client" do
        expect(output).to eql "new\n"
      end
    end # End context Single
    
  end # end context Status
  
  context "Delete" do

    context "Single" do
      let(:output) { capture(:stdout) { subject.delete 'test-client' } }

      it "does not contain client" do
        expect(output).not_to include '---
test-client:
  :type: :linux
  :server: test-server
  :status: :new
  :error: 
  :data:
    :ip_address: 0.0.0.1
    :username: test-value2
    :password: test-value2
'          
      end
    end # End context Single

    context "Non-existing" do
      let(:output) { capture(:stdout) { subject.delete 'test-client' } }

      it "does not contain client" do
        expect(output).to eql "ERROR : client with name 'test-client' does not exist\n"
      end
    end # End context Non-existing

  end # End context Delete

end
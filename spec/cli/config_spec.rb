require 'spec_helper'

describe Netjoin::Cli::Config do

  context "Database" do

    context "Show" do
      let(:output) { capture(:stdout) { subject.database } }

      it "Show correct database name" do
        expect(output).to eql "---
:database: database-test
"
      end
    end # End context Show

    context "Change" do
      let(:output) { capture(:stdout) {
          subject.options = {:name => 'test'}
          subject.database
      } }

      it "Changes the database name" do
        expect(output).to eql "---
:database: test
"
      end

      it "Creates the missing file" do
        expect(File.file?('test.yml')).to eql true
      end

    end # End context Change

  end # End context Database

end
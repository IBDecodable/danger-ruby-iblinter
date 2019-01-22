# frozen_string_literal: true

require File.expand_path("spec_helper", __dir__)

module Danger
  describe Danger::DangerIblinter do
    it "should be a plugin" do
      expect(Danger::DangerIblinter.new(nil)).to be_a Danger::Plugin
    end

    describe "with Dangerfile" do
      before do
        @dangerfile = testing_dangerfile
        @iblinter = @dangerfile.iblinter

        # mock the PR data
        # you can then use this, eg. github.pr_author, later in the spec
        json = File.read(File.dirname(__FILE__) + "/support/fixtures/github_pr.json")
        allow(@iblinter.github).to receive(:pr_json).and_return(json)
      end

      it "inline comment works with relative path" do
        linter = IBLinterRunner.new("/path/to/binary")
        allow(linter).to receive(:lint) do
          JSON.parse(File.read(File.dirname(__FILE__) + "/support/fixtures/iblinter.json"))
        end
        allow(@iblinter).to receive(:iblinter).and_return(linter)
        allow(@iblinter).to receive(:iblinter_installed?).and_return(true)
        allow(Dir).to receive(:pwd).and_return("/home/projects")
        allow(File).to receive(:exist?).and_return(true)
        @iblinter.lint("/home/projects")
        errors = [
          Violation.new("Error message", false, "bar/File.xib", 0),
          Violation.new("Failed due to IBLinter errors", false, nil, nil)
        ]
        warnings = [
          Violation.new("Warning message", false, "foo/File.xib", 0)
        ]
        expect(@iblinter.violation_report[:errors]).to eq errors
        expect(@iblinter.violation_report[:warnings]).to eq warnings
      end
    end
  end
end

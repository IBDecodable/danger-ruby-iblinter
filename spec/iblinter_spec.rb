# frozen_string_literal: true

require File.expand_path("spec_helper", __dir__)
require_relative "../lib/iblinter/iblinter"

describe IBLinterRunner do
  context "binary_path is passed" do
    it "should return valid command" do
      binary_path = File.absolute_path "path/to/binary"
      options = {}
      cmd = "#{binary_path} lint --reporter json"
      iblinter = IBLinterRunner.new(binary_path, nil)
      expect(iblinter.lint_command(options)).to eq cmd
    end
  end

  context "execute_command is passed" do
    it "should return valid command" do
      execute_command = "swift run iblinter"
      options = {}
      cmd = "swift run iblinter lint --reporter json"
      iblinter = IBLinterRunner.new(nil, execute_command)
      expect(iblinter.lint_command(options)).to eq cmd
    end
  end

  context "binary_path and execute_command are passed" do
    it "binary_path should be ignored" do
      binary_path = File.absolute_path "path/to/binary"
      execute_command = "swift run iblinter"
      options = {}
      cmd = "swift run iblinter lint --reporter json"
      iblinter = IBLinterRunner.new(binary_path, execute_command)
      expect(iblinter.lint_command(options)).to eq cmd
    end
  end
end

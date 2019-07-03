# frozen_string_literal: true

require File.expand_path("spec_helper", __dir__)
require_relative "../lib/iblinter/iblinter"

describe IBLinterRunner do
  let(:options) { {} }
  let(:cmd) { "swift run iblinter lint --reporter json" }
  let(:binary_path) { nil }
  let(:execute_command) { nil }
  let(:iblinter) { IBLinterRunner.new(binary_path, execute_command) }

  context "binary_path is passed" do
    let(:binary_path) { File.absolute_path "path/to/binary" }
    let(:cmd) { "#{binary_path} lint --reporter json" }

    it "should return valid command" do
      expect(iblinter.lint_command(options)).to eq cmd
    end
  end

  context "execute_command is passed" do
    let(:execute_command) { "swift run iblinter" }

    it "should return valid command" do
      expect(iblinter.lint_command(options)).to eq cmd
    end
  end

  context "binary_path and execute_command are passed" do
    let(:execute_command) { "swift run iblinter" }
    let(:binary_path) { File.absolute_path "path/to/binary" }

    it "should ignore binary_path" do
      expect(iblinter.lint_command(options)).to eq cmd
    end
  end
end

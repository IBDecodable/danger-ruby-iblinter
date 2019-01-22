# frozen_string_literal: true

require File.expand_path("spec_helper", __dir__)
require_relative "../lib/iblinter/iblinter"

describe IBLinter do
  it "command arguments works" do
    binary_path = File.absolute_path "path/to/binary"
    options = {}
    cmd = "#{binary_path} lint --reporter json"
    iblinter = IBLinter.new(binary_path)
    expect(iblinter.lint_command(options)).to eq cmd
  end
end

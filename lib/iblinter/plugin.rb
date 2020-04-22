# frozen_string_literal: true

require_relative "./iblinter"

module Danger
  # Lint Interface Builder files inside your projects.
  # This is done using the [IBLinter](https://github.com/IBDecodable/IBLinter) tool.
  #
  # @example Specifying custom config file and path.
  #
  #          iblinter.config_file = ".iblinter.yml"
  #          iblinter.lint
  #
  # @see  IBDecodable/IBLinter
  # @tags swift
  #
  class DangerIblinter < Plugin
    # The path to IBLinter"s execution
    # @return  [void]
    attr_accessor :binary_path
    attr_accessor :execute_command

    # Lints IB files. Will fail if `iblinter` cannot be installed correctly.
    # @return   [void]
    #
    def lint(path = Dir.pwd, fail_on_warning: false, inline_mode: true, options: {})
      unless @execute_command || iblinter_installed?
        raise "iblinter is not installed"
      end

      issues = iblinter.lint(path, options)
      return if issues.empty?

      errors = issues.select { |v| v["level"] == "error" }
      warnings = issues.select { |v| v["level"] == "warning" }

      if inline_mode
        send_inline_comment(warnings, fail_on_warning ? :fail : :warn)
        send_inline_comment(errors, :fail)
      else
        message = "### IBLinter found issues\n\n"
        message << markdown_issues(errors, "Errors", ":rotating_light:") unless errors.empty?
        message << markdown_issues(warnings, "Warnings", ":warning:") unless warnings.empty?
        markdown message
      end
    end

    # Instantiate iblinter
    # @return     [IBLinterRunner]
    def iblinter
      IBLinterRunner.new(@binary_path, @execute_command)
    end

    private

    def iblinter_installed?
      if !@binary_path.nil? && File.exist?(@binary_path)
        return true
      end

      !`which iblinter`.empty?
    end

    def markdown_issues(results, heading, emoji)
      message = "#### #{heading}\n\n"

      message << "|   | File | Hint |\n"
      message << "|---| ---- | -----|\n"

      results.each do |r|
        filename = r["file"].split("/").last
        hint = r["message"]
        message << "| #{emoji} | #{filename} | #{hint} | \n"
      end

      message
    end

    def send_inline_comment(results, method)
      dir = "#{Dir.pwd}/"
      results.each do |r|
        filename = r["file"].gsub(dir, "")
        send(method, r["message"], file: filename, line: 0)
      end
    end
  end
end

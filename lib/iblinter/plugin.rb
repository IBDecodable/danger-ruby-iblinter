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
      issues = filter_git_diff_issues(issues)
      
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

    # Filters issues reported against changes in the modified files
    #
    # @return [Array] swiftlint issues
    def filter_git_diff_issues(issues)
      modified_files_info = git_modified_files_info()
      return issues.select { |i| 
           modified_files_info["#{i['file']}"] != nil
        }
    end
    
    # Finds modified files and added files, creates array of files with modified line numbers
    #
    # @return [Array] Git diff changes for each file
    def git_modified_files_info()
        modified_files_info = Hash.new
        updated_files = (git.modified_files - git.deleted_files) + git.added_files
        updated_files.each {|file|
            modified_lines = git_modified_lines(file)
            modified_files_info[File.expand_path(file)] = modified_lines
        }
        modified_files_info
    end
    
    # Gets git patch info and finds modified line numbers, excludes removed lines
    #
    # @return [Array] Modified line numbers i
    def git_modified_lines(file)
      git_range_info_line_regex = /^@@ .+\+(?<line_number>\d+),/ 
      git_modified_line_regex = /^\+(?!\+|\+)/
      git_removed_line_regex = /^[-]/
      git_not_removed_line_regex = /^[^-]/
      file_info = git.diff_for_file(file)
      line_number = 0
      lines = []
      file_info.patch.split("\n").each do |line|
          starting_line_number = 0
          case line
          when git_range_info_line_regex
              starting_line_number = Regexp.last_match[:line_number].to_i
          when git_modified_line_regex
              lines << line_number
          end
          line_number += 1 if line_number > 0
          line_number = starting_line_number if line_number == 0 && starting_line_number > 0
      end
      lines
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
        send(method, r["message"], file: filename, line: 1)
      end
    end
  end
end

# frozen_string_literal: true

class IBLinter
  def initialize(binary_path)
    @binary_path = binary_path
  end

  def run(command)
    `#{command}`
  end

  def lint(path, options)
    Dir.chdir path
    JSON.parse(run(lint_command(options)))
  end

  def lint_command(options)
    abs_binary_path = @binary_path.nil? ? "iblinter" : File.absolute_path(@binary_path)
    "#{abs_binary_path} lint #{arguments(options.merge(reporter: 'json'))}"
  end

  # Parse options into shell arguments.
  # Reference  https://github.com/ashfurrow/danger-ruby-swiftlint/blob/0af6d5aff38dc666352ea3750266fb7630d88bdd/ext/swiftlint/swiftlint.rb#L38
  def arguments(options)
    options.
      reject { |_key, value| value.nil? }.
      map { |key, value| value.kind_of?(TrueClass) ? [key, ""] : [key, value] }.
      # map booleans arguments equal false
      map { |key, value| value.kind_of?(FalseClass) ? ["no-#{key}", ""] : [key, value] }.
      # replace underscore by hyphen
      map { |key, value| [key.to_s.tr("_", "-"), value] }.
      # prepend "--" into the argument
      map { |key, value| ["--#{key}", value] }.
      # reduce everything into a single string
      reduce("") { |args, option| "#{args} #{option[0]} #{option[1]}" }.
      # strip leading spaces
      strip
  end
end

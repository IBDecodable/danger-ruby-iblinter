# Danger IBLinter

[![Build Status](https://travis-ci.org/IBDecodable/danger-ruby-iblinter.svg?branch=master)](https://travis-ci.org/IBDecodable/danger-ruby-iblinter) [![Gem Version](https://badge.fury.io/rb/danger-iblinter.svg)](https://badge.fury.io/rb/danger-iblinter)

A danger plugin for IBLinter.

## Installation

```ruby
gem 'danger-iblinter'
```

This plugin requires `iblinter` executable binary.

## Usage

```ruby
iblinter.binary_path = "./Pods/IBLinter/bin/iblinter"
iblinter.lint("./path/to/project", fail_on_warning: true, inline_mode: true)
```

```ruby
iblinter.execute_command = "swift run iblinter"
iblinter.lint("./path/to/project", fail_on_warning: true, inline_mode: true)
```

|     parameter   | default |
|:---------------:|:-------:|
| fail_on_warning |  false  |
|   inline_mode   |  true   |


## Development

1. Clone this repo
2. Run `bundle install` to setup dependencies.
3. Run `bundle exec rake spec` to run the tests.
4. Use `bundle exec guard` to automatically have tests run as you make changes.
5. Make your changes.

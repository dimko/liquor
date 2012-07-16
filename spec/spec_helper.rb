# This file was generated by the `rspec --init` command. Conventionally, all
# specs live under a `spec` directory, which RSpec adds to the `$LOAD_PATH`.
# Require this file using `require "spec_helper.rb"` to ensure that it is only
# loaded once.
#
# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration

require 'liquor'

module LiquorSpecHelpers
  def lex(string)
    Liquor::Lexer.lex(string)
  end

  def parse(string)
    parser = Liquor::Parser.new
    if parser.parse string
      parser.ast
    elsif parser.errors.count == 1
      raise parser.errors.first
    else
      raise Exception, "more than one error"
    end
  end

  def compile(string)
    compiler = Liquor::Compiler.new
    compiler.compile! string
  end

  def exec(string, env={})
    compile(string).call(env)
  end
end

RSpec.configure do |config|
  config.include LiquorSpecHelpers
end

RSpec::Matchers.define :have_token_structure do |*expected|
  match do |actual|
    expected.zip(actual).all? do |tok_expected, tok_actual|
      expected_type, expected_value = *tok_expected
      actual_type, actual_pos, actual_value = *tok_actual

      expected_type == actual_type &&
          (expected_value.nil? || expected_value == actual_value)
    end
  end
end

RSpec::Matchers.define :have_node_structure do |*expected|
  to_structure = ->(tree) {
    if tree.is_a?(Array)
      if tree[0].is_a?(Symbol)
        [ tree[0], *tree[2..-1].map(&to_structure) ]
      else
        tree.map(&to_structure)
      end
    elsif tree.is_a?(Hash)
      tree = tree.dup
      tree.each do |k, v|
        tree[k] = to_structure.(v)
      end
    else
      tree
    end
  }

  match do |actual|
    actual.map(&to_structure) == expected
  end
end
require "spec_helper"

describe Liquor::Library do
  it "allows to define a function and export them to a compiler" do
    lib = Module.new do
      include Liquor::Library

      function "hello" do |arg, kw|
        "hello world"
      end
    end

    compiler = Liquor::Compiler.new
    lib.export compiler
    compiler.compile '{{ hello() }}'
    compiler.code.call.should == 'hello world'
  end
end
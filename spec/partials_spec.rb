require "spec_helper"

describe Liquor::Partials do
  it "should provide content_for and yield" do
    exec(%Q|
      {% yield "test" %}
      1
      {% content_for "test" capture: %}
        data
      {% end content_for %}
      2
      {% yield "test" %}
      {% yield "test" %}
    |).scan(/\w+/).should == %w(1 2 data data)
  end

  it "should have working include" do
    manager = Liquor::Manager.new
    manager.register_template 'layout', '1 {% assign x = 2 %}{% include "action" %} 3'
    manager.register_partial '_action', '{{ x }}'
    manager.compile.should be_true
    manager.render('layout').should == '1 2 3'
  end

  it "should create a scope" do
    manager = Liquor::Manager.new
    manager.register_template 'layout', '1 {% assign x = 2 %}{% include "action" %} 3 {{ x }}'
    manager.register_partial '_action', '{% assign x = "G" %}{{ x }}'
    manager.compile.should be_true
    manager.render('layout').should == '1 G 3 2'
  end

  it "should emit correct error messages" do
    manager = Liquor::Manager.new
    manager.register_template 'layout', '{% assign x = 2 %} {% include "action" %}'
    manager.register_partial '_action', '{{ y }}'

    manager.compile.should be_false

    manager.errors.count.should == 1
    manager.errors.first.should be_a Liquor::NameError
    manager.errors.first.message.should =~ %r|identifier `y' is not bound at `_action'|
  end
end
require 'spec_helper'

describe Thought do
  before(:all) { @item_class = Thought }
  it_should_behave_like 'an item'
end

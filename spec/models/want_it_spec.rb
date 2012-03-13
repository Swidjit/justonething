require 'spec_helper'

describe WantIt do
  before(:all) { @item_class = WantIt }
  it_should_behave_like 'an item'
end

require 'spec_helper'

describe ItemPresetTag do
  describe "supports reading and writing:" do

    it 'a tag' do
      subject.tag = 'tagged'
      subject.tag.should == 'tagged'
    end

    it 'an item type' do
      subject.item_type = 'Event'
      subject.item_type.should == 'Event'
    end

  end
end
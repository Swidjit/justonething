require 'spec_helper'

describe City do
  describe 'supports reading and writing of' do
    it 'a url_name' do
      subject.url_name = 'ithaca'
      subject.url_name.should == 'ithaca'
    end
    it 'a display_name' do
      subject.display_name = 'Ithaca'
      subject.display_name.should == 'Ithaca'
    end
  end
end

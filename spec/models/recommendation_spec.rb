require 'spec_helper'

describe Recommendation do
  describe "supports reading and writing:" do

    it 'a description' do
      subject.description = 'Singlebrook'
      subject.description.should == 'Singlebrook'
    end

  end

  it { should belong_to :user }
  it { should belong_to :item }
end

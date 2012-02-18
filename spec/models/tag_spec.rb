require 'spec_helper'

describe Tag do
  describe "supports reading and writing:" do

    it 'a name' do
      subject.name = 'tagged'
      subject.name.should == 'tagged'
    end

  end

  it { should have_and_belong_to_many :items }
end
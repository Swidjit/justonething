require 'spec_helper'

describe Community do
  describe "supports reading and writing:" do

    it 'a name' do
      subject.name = 'Singlebrook'
      subject.name.should == 'Singlebrook'
    end

    it 'a description' do
      subject.description = 'Web developers'
      subject.description.should == 'Web developers'
    end

  end

  it { should belong_to :user }
end

require 'spec_helper'

describe List do
  describe "supports reading and writing:" do

    it 'a name' do
      subject.name = 'Singlebrook'
      subject.name.should == 'Singlebrook'
    end

  end

  it { should belong_to :user }

  it { should have_and_belong_to_many :users }
end

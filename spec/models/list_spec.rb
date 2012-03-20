require 'spec_helper'

describe List do
  describe "supports reading and writing:" do

    it 'a name' do
      subject.name = 'Singlebrook'
      subject.name.should == 'Singlebrook'
    end

  end

  it { should belong_to :user }

  it { should have_many :users }
end

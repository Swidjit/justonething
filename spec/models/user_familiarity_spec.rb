require 'spec_helper'

describe UserFamiliarity do
  describe "supports reading and writing:" do

    it 'a familiarness' do
      subject.familiarness = 14
      subject.familiarness.should == 14
    end

  end

  it { should belong_to :user }
  it { should belong_to :familiar }
end

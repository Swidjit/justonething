require 'spec_helper'

describe Tag do
  describe "supports reading and writing:" do

    it 'should not be all numbers' do
      Factory.build(:tag, :name => '1').should_not be_valid
    end

    it 'can begin with a number' do
      Factory.build(:tag, :name => '1n').should be_valid
    end

    it 'can contain only letters' do
      Factory.build(:tag, :name => 'n').should be_valid
    end

    it 'a name' do
      subject.name = 'tagged'
      subject.name.should == 'tagged'
    end

    it "should not leak into geo tags" do
      Tag.create(:name => 'foo')
      gt = GeoTag.new(:name => 'foo')
      gt.should be_valid
      gt.save

      Tag.all.count.should == 1
      GeoTag.all.count.should == 1
    end

  end

  it { should have_and_belong_to_many :items }
end

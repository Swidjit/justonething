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

  it 'should delete item visibility rules when destroyed' do
    l = Factory(:list)
    i = Factory(:thought)
    i.item_visibility_rules << ItemVisibilityRule.new( :visibility_id => l.id, :visibility_type => 'List' )
    ItemVisibilityRule.all.count.should == 2
    l.destroy
    ItemVisibilityRule.all.count.should == 1
  end
end

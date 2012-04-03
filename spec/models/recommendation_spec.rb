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

  it 'should update user familiarity for mentions on save' do
    user = Factory(:user)
    user2 = Factory(:user)
    rec = Factory(:recommendation, :user => user, :description => "Awesome find @#{user2.display_name}")
    uf = UserFamiliarity.find_by_user_id_and_familiar_id(user.id,user2.id)
    uf.familiarness.should > 0
  end

  it 'should update user familiarity for recommends on save' do
    rec = Factory(:recommendation)
    uf = UserFamiliarity.find_by_user_id_and_familiar_id(rec.user.id,rec.item.user.id)
    uf.familiarness.should > 0
  end

  it 'should notify item owner after creation' do
    rec = Factory(:recommendation)
    rec.item.user.notifications.count.should > 0
  end

  it_behaves_like "a referencing object", { :factory => :recommendation, :fields => %w( description ) }
end

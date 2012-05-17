require 'spec_helper'

describe Comment do
  describe "supports reading and writing of" do
    it "a text" do
      subject.text = 'This is off the wall!'
      subject.text.should == 'This is off the wall!'
    end
  end

  it { should belong_to :item }
  it { should belong_to :user }

  it 'should notify item owner after creation only if it is a top level comment' do
    comment = Factory(:comment)
    comment.item.user.notifications.count.should == 1

    start_size = ActionMailer::Base.deliveries.size
    reply = Factory(:comment, :parent_id => comment.id)

    comment.item.user.notifications.count.should == 1
    ActionMailer::Base.deliveries.size.should == start_size + 1
  end

  it 'should notify comment poster after reply' do
    comment = Factory(:comment)

    start_size = ActionMailer::Base.deliveries.size
    reply = Factory(:comment, :parent_id => comment.id)

    comment.user.notifications.count.should == 1
    ActionMailer::Base.deliveries.size.should == start_size + 1
  end

  it_behaves_like "a referencing object", { :factory => :comment, :fields => %w( text ) }
end

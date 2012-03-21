require 'spec_helper'

describe CommentsController do
  describe 'create new' do
    it 'should successfullly create comment' do
      user = Factory(:user)
      item = Factory(:have_it)
      sign_in user
      item.comments.count.should == 0
      post :create, :comment => {:text => "I'm commenting LOLS"}, :id => item.id
      item.comments.count.should == 1
    end

    it 'should successfullly create nested comment' do
      user = Factory(:user)
      comment = Factory(:comment)
      item = comment.item
      sign_in user
      item.comments.count.should == 1
      post :create, :comment => {:text => "I'm commenting LOLS", :parent_id => comment.id }, :id => item.id
      item.comments.count.should == 2
      comment.children.count.should == 1
    end
  end
end

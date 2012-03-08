require 'spec_helper'

describe DelegatesControllerController do
  before(:each) { request.env["HTTP_REFERER"] = "/" }

  context "logged in user" do
    context "creating a new delegate" do
      before(:each) do
        sign_in Factory(:user)
        delegatee = Factory(:user)
        post :create, :delegatee_id => delegatee.id
      end

      it "should redirect" do
        response.should be_redirect
      end
      it "should add a delegate record" do
        Delegate.count.should == 1
      end
    end

    context "deleting an existing delegate" do
      before(:each) do
        @delegation = Factory(:delegate)
      end

      it "as someone who is not the delegator should not reduce the number of delegates" do
        sign_in @delegation.delegatee
        delete :destroy, :id => @delegation.id

        Delegate.count.should == 1
      end

      it "as the delegator should reduce the number of delegates" do
        sign_in @delegation.delegator
        delete :destroy, :id => @delegation.id

        Delegate.count.should == 0
      end
    end
  end
end

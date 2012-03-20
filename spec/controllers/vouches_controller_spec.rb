require 'spec_helper'

describe VouchesController do
  describe 'vouching for a user' do
    before(:each) do
      @voucher = Factory(:user)
      @vouchee = Factory(:user)
      sign_in @voucher
    end

    it 'should be successful when valid' do
      post :create, :id => @vouchee.id
      @vouchee.vouches.count.should == 1
    end

    it 'should not allow a user to vouch for themselves' do
      post :create, :id => @voucher.id
      @voucher.vouches.count.should == 0
    end

    it 'should not allow a user to vouch multiple times for another user' do
      post :create, :id => @vouchee.id
      @vouchee.vouches.count.should == 1
      post :create, :id => @vouchee.id
      @vouchee.vouches.count.should == 1
    end
  end
end

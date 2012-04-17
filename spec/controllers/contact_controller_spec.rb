require 'spec_helper'

describe ContactController do

  before(:each) do
    @user = Factory(:user)
  end

  describe "GET index" do
    it 'should load the contact form' do
      get :new
      page.should
    end
  end

  describe "POST index" do
    it 'should send the contact form' do
      get :create, :subject => "Form", :message => {
        :name => "Angela Groupie",
        :email => "user@swidjitgroupie.com",
        :subject => "Swidjit rocks",
        :body => "I love this service!"
      }
      response.should redirect_to(root_path)
      flash[:notice].should =~ /message/i
    end
  end
end
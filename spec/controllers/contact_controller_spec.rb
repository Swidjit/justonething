require 'spec_helper'

describe ContactController do
  describe "GET index" do
    it 'should load the contact form' do
      get :new
      page.should
    end
  end

  describe "POST create" do
    it 'should send the contact form' do
      mail_before = ActionMailer::Base.deliveries.size
      post :create, :subject => "Form", :message => {
        :name => "Angela Groupie",
        :email => "user@swidjitgroupie.com",
        :subject => "Swidjit rocks",
        :body => "I love this service!"
      }
      ActionMailer::Base.deliveries.size.should == mail_before + 1
      response.should redirect_to(root_path)
      flash[:notice].should =~ /message/i
    end
  end
end

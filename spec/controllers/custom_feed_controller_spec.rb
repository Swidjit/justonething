require 'spec_helper'

describe CustomFeedController do

  describe "GET 'new'" do
    it "returns http success" do
      get 'new'
      response.should be_success
    end
  end

  describe "GET 'show'" do
    it "returns http success" do
      get 'show'
      response.should be_success
    end
  end

  describe "GET 'create'" do
    it "returns http success" do
      get 'create'
      response.should be_success
    end
  end

  describe "GET 'destroy'" do
    it "returns http success" do
      get 'destroy'
      response.should be_success
    end
  end

  describe "GET 'add_element'" do
    it "returns http success" do
      get 'add_element'
      response.should be_success
    end
  end

  describe "GET 'remove_element'" do
    it "returns http success" do
      get 'remove_element'
      response.should be_success
    end
  end

end

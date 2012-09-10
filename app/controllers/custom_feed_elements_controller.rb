class CustomFeedElementsController < ApplicationController
  
  before_filter :load_and_authorize_list, :only => [:add_element]
  
  def new
  end

  def index
  end

  def create
    @custom_feed_element = new CustomFeedElement
  end

  def destroy
  end
  
  
  
  private
  
  def load_and_authorize_list
    @custom_feed = CustomFeed.find(params[:id])
  end
end

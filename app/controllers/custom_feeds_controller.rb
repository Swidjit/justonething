class CustomFeedsController < ApplicationController
  #before_filter :authenticate_user!, :only => :familiar_users
  before_filter :load_and_authorize_list, :only => [:add_element]
  respond_to :json, :html
  def index
    
    
    render_paginated_feed :index
  end
  
  def new
    @custom_feed = CustomFeed.new
    @custom_feed.name = params[:custom_feed][:name]
    @custom_feed.user = current_user

  end

  def show
    @feed_items = []
    @custom_feed = CustomFeed.find(params[:id])
    @custom_feed.elements.each do |e| 
      e.inspect     
      if e.element_type == "tag"
        @tag = Tag.find_by_name(e.element_name)
        if @tag.present?  
          @feed_items << @tag.items.access_controlled_for(current_user, current_city, current_ability)
        end
      end
    end
    render_paginated_feed :show
    #@feed_items = filter_by_type_and_access(@feed_items)
    #@feed_items = @community.items.access_controlled_for(current_user, current_city, current_ability)
    
    #@feed_items >> @user.items.access_controlled_for(current_user, current_city, current_ability)
  end

  def create
    @custom_feed = CustomFeed.create(params[:custom_feed])
    @custom_feed.user_id = current_user.id
    @custom_feed.save
    
    @subscription = CustomFeedSubscription.create(:user_id => current_user.id, :custom_feed_id => @custom_feed.id)
    @subscription.save
    
    respond_with @custom_feed
  end

  def destroy
  end
  
  def add_element
    element = CustomFeedElement.new
    element.custom_feed_id = @custom_feed.id
    element.element_name = params[:title]
    element.element_type = params[:feed_type]
    
    if @custom_feed.elements.include?(element)
      notice = "User already in list #{@custom_feed.name}"
      success_val = false
    else
      @custom_feed.elements << element
      notice = "Successfully added user to #{@custom_feed.name}"
      success_val = true
      redirect_to :back
    end
    
  end
  
  private
  
  def load_and_authorize_list
    @custom_feed = CustomFeed.find(params[:id])
  end
  
  def filter_by_type_and_access(feed_items)
    @type = (params[:type] ||= 'all')
    if Item.classes.map{|kls| kls.underscore.pluralize }.include? @type
      feed_items = feed_items.where({:type => @type.singularize.camelize})
      if @type == 'events'
        feed_items = feed_items.includes(:rsvp_users)
      end
    else
      @type = 'all'
    end
    @type_link = @type
    @type = @type.titleize
    feed_items.includes(:tags, :geo_tags, :collections, :bookmark_users, :item_flag_users, :thumbnail, :user
      ).access_controlled_for(current_user, current_city, current_ability)
  end

end

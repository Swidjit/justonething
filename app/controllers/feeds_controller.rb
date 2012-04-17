class FeedsController < ApplicationController
  before_filter :authenticate_user!, :only => :familiar_users

  def all
    if params[:tag_name].present?
      @tag = Tag.find_by_name(params[:tag_name])
      @feed_title = "All Items with Tag: #{params[:tag_name]}"
      if @tag.present?
        @feed_items = @tag.items.access_controlled_for(current_user,current_ability)
      else
        @feed_items = []
        render :index and return
      end
    else
      @feed_items = Item.access_controlled_for(current_user,current_ability)
      @feed_title = "All Items"
    end
    render_paginated_feed :index
  end

  %w( HaveIt WantIt Event Thought Link ).each do |item_type|
    define_method item_type.underscore.pluralize do
      if params[:tag_name].present?
        @tag = Tag.find_by_name(params[:tag_name])
        @feed_title = "#{item_type.titleize.pluralize} with Tag: #{params[:tag_name]}"
        if @tag.present?
          @feed_items = @tag.items.where({:type => item_type}).access_controlled_for(current_user,current_ability)
        else
          @feed_items = []
          render :index and return
        end
      else
        @feed_items = item_type.constantize.access_controlled_for(current_user,current_ability)
        @feed_title = item_type.titleize.pluralize
      end
      render_paginated_feed :index
    end
  end

  def drafts
    @feed_items  = current_user.items.deactivated
    render_paginated_feed :drafts
  end

  def search
    if params[:q].present?
      @terms = params[:q]
      @type = (params[:type] || 'all').singularize.camelize
      @title = "Search for #{@terms}"
      @feed_items = Item.search(@terms)
      if @type && %w( HaveIt WantIt Event Thought Link ).include?(@type)
        @feed_items = @feed_items.where({:type => @type})
      end
      @feed_items = @feed_items.access_controlled_for(current_user,current_ability)
    else
      @title = "Search for"
      @feed_items = []
    end
    render_paginated_feed :generic_index
  end

  def recommendations
    item_type = params[:type] || 'all'
    if %w( events have_its want_its links thoughts ).include? item_type
      @feed_items = Item.recommended.where(:type => item_type.camelize.singularize).access_controlled_for(current_user,current_ability)
    else
      params[:type] = 'all'
      @feed_items = Item.recommended.access_controlled_for(current_user,current_ability)
    end
    render_paginated_feed :generic_index
  end

  def familiar_users
    @title = 'Feed of Your Most Familiar Users'
    item_type = params[:type] || 'all'
    base_feed_items = Item.where("#{Item.table_name}.user_id IN (?)",current_user.familiar_users.limit(25).collect(&:id))
    if %w( events have_its want_its links thoughts ).include? item_type
      @feed_items = base_feed_items.where(:type => item_type.camelize.singularize).access_controlled_for(current_user,current_ability)
    else
      params[:type] = 'all'
      @feed_items = base_feed_items.access_controlled_for(current_user,current_ability)
    end
    @test_output = current_user.familiar_users.limit(25)
    render_paginated_feed :generic_index
  end

  # Per discussion between Isaiah and Sonny: single action for each item type
  # Eventually List action
  # Index action with query string that combines all types of filtering

end

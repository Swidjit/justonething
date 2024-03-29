class FeedsController < ApplicationController
  before_filter :authenticate_user!, :only => :familiar_users

  def index
    item_type = params[:type] || 'all'
    if %w( events have_its want_its links thoughts ).include? item_type
      @valid_type = item_type.titleize
      @feed_items = Item.of_type(item_type.camelize.singularize).access_controlled_for(current_user, current_city, current_ability)
    else
      @valid_type = 'All'
      @feed_items = Item.access_controlled_for(current_user, current_city, current_ability)
    end
    if params[:tags].present?
      @tags = params[:tags].split(',')
      @tags.each do |tag|
        @feed_items = @feed_items.having_tag_with_name(tag)
      end
    end
    #@feed_items = @feed_items.access_controlled_for(current_user, current_city, current_ability)
    render_paginated_feed :index
  end

  def index_old
    if params[:tag_name].present?
      @tag = Tag.find_by_name(params[:tag_name])
      @title = %& "#{params[:tag_name]}"&
      @feed_type = "tag"
      if @tag.present?
        @feed_items = filter_by_type_and_access(@tag.items)
      else
        @feed_items = []
      end
    else
      @hide_tabbed_types = true
      @feed_items = filter_by_type_and_access(Item)
    end

    item_type_string = @type == 'items ' ? '' : @type
    unless @title.nil?
      @title = "#{item_type_string} tagged " + @title
    else
      @title = item_type_string
    end
    #- @title = @title + " feed [#{item_type_string}]"

    render_paginated_feed :index
  end

  def drafts
    @feed_items  = Item.inactive.where(:user_id => current_user.id).order('expires_on desc')
    render_paginated_feed :drafts
  end

  def search
    if params[:q].present?
      @terms = params[:q]
      @title = "Search for #{@terms}"
      @feed_items = filter_by_type_and_access(Item.search(@terms))
    else
      @title = "Search for"
      @feed_items = []
    end
    render_paginated_feed :index
  end

  def recommendations
    @feed_items = filter_by_type_and_access(Item.recommended)
    @title = "#{@type}"

    render_paginated_feed :index
  end

  def familiar_users
    @title = 'Feed of Your Most Familiar Users'
    base_feed_items = Item.where("#{Item.table_name}.user_id IN (?)",current_user.familiar_users.limit(25).collect(&:id))
    @feed_items = filter_by_type_and_access(base_feed_items)

    render_paginated_feed :index
  end

  def geo
    @tag = GeoTag.find_by_name(params[:tag_name])
    @feed_items = filter_by_type_and_access(@tag.items)
    @title = "#{@type} Items with Geo Tag: #{params[:tag_name]}"

    render_paginated_feed :index
  end
  
  def suggested_items
    @title = 'Feed of Your Most Familiar Users'
    base_feed_items = SuggestedItem.where('suggested_user_id = ?', current_user.id)
    @title = "#{@type} Suggested Items: #{params[:tag_name]}"
    @feed_items = filter_by_type_and_access(base_feed_items)

    render_paginated_feed :index
  end

  def nearby
    @type = (params[:type] || 'all').singularize.camelize
    if @type == 'all'
      @title = "All Nearby Items"
    else
      @title = "Nearby #{@type} Items"
    end

    if %w( events have_its want_its links thoughts ).include? @type
      @feed_items = Item.where({:type => @type}).having_geo_tags(current_user.geo_tags).access_controlled_for(current_user,current_city,current_ability)
    else
      @feed_items = Item.having_geo_tags(current_user.geo_tags).access_controlled_for(current_user,current_city,current_ability)
    end

    render_paginated_feed :index
  end

  # Per discussion between Isaiah and Sonny: single action for each item type
  # Eventually List action
  # Index action with query string that combines all types of filtering

  private
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

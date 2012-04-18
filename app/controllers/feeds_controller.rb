class FeedsController < ApplicationController
  before_filter :authenticate_user!, :only => :familiar_users

  def index
    if params[:tag_name].present?
      @tag = Tag.find_by_name(params[:tag_name])
      @title = " with Tag: #{params[:tag_name]}"
      if @tag.present?
        @feed_items = filter_by_type_and_access(@tag.items)
      else
        @feed_items = []
      end
    else
      @hide_tabbed_types = true
      @feed_items = filter_by_type_and_access(Item)
    end

    item_type_string = @type == 'All' ? 'All Items' : @type
    @title = "Feed for #{item_type_string}" + (@title || '')

    render_paginated_feed :index
  end

  def drafts
    @feed_items  = current_user.items.deactivated
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

  # Per discussion between Isaiah and Sonny: single action for each item type
  # Eventually List action
  # Index action with query string that combines all types of filtering

  private
  def filter_by_type_and_access(feed_items)
    @type = (params[:type] ||= 'all')
    if Item.classes.map{|kls| kls.underscore.pluralize }.include? @type
      feed_items = feed_items.where({:type => @type.singularize.camelize})
    end
    @type = @type.titleize
    feed_items.access_controlled_for(current_user,current_ability)
  end

end

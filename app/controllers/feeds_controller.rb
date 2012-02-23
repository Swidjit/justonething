class FeedsController < ApplicationController

  def all
    if params[:tag_name].present?
      @tag = Tag.find_by_name(params[:tag_name])
      @feed_items = @tag.items.accessible_by(current_ability)
      @feed_title = "All Items with Tag: #{params[:tag_name]}"
    else
      @feed_items = Item.accessible_by(current_ability)
      @feed_title = "All Items"
    end
    @feed_items = @feed_items
    render :index
  end

  %w( HaveIt WantIt Event Thought Link ).each do |item_type|
    define_method item_type.underscore.pluralize do
      if params[:tag_name].present?
        @tag = Tag.find_by_name(params[:tag_name])
        @feed_items = @tag.items.where({:type => item_type}).accessible_by(current_ability)
        @feed_title = "#{item_type.titleize.pluralize} with Tag: #{params[:tag_name]}"
      else
        @feed_items = item_type.constantize.accessible_by(current_ability)
        @feed_title = item_type.titleize.pluralize
      end
      @feed_items = @feed_items
      render :index
    end
  end

  # Per discussion between Isaiah and Sonny: single action for each item type
  # Eventually List action
  # Index action with query string that combines all types of filtering

end

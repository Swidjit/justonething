class FeedsController < ApplicationController

  def all
    if params[:tag_name].present?
      @tag = Tag.find_by_name(params[:tag_name])
      if @tag.present?
        @feed_items = @tag.items.access_controlled_for(current_user,current_ability)
      else
        @feed_items = []
      end
      @feed_title = "All Items with Tag: #{params[:tag_name]}"
    else
      @feed_items = Item.access_controlled_for(current_user,current_ability)
      @feed_title = "All Items"
    end
    @feed_items = @feed_items
    render :index
  end

  %w( HaveIt WantIt Event Thought Link ).each do |item_type|
    define_method item_type.underscore.pluralize do
      if params[:tag_name].present?
        @tag = Tag.find_by_name(params[:tag_name])
        if @tag.present?
          @feed_items = @tag.items.where({:type => item_type}).access_controlled_for(current_user,current_ability)
        else
          @feed_items = []
        end
        @feed_title = "#{item_type.titleize.pluralize} with Tag: #{params[:tag_name]}"
      else
        @feed_items = item_type.constantize.access_controlled_for(current_user,current_ability)
        @feed_title = item_type.titleize.pluralize
      end
      @feed_items = @feed_items
      render :index
    end
  end

  def drafts
    @feed_items  = current_user.items.deactivated
  end

  # Per discussion between Isaiah and Sonny: single action for each item type
  # Eventually List action
  # Index action with query string that combines all types of filtering

end

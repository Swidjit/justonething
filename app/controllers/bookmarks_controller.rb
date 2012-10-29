class BookmarksController < ApplicationController
  authorize_resource :only => :destroy
  before_filter :load_resource, :only => :destroy

  def index
    if current_user.nil?
      redirect_to '/'
      return
    end
    @feed_items = current_user.bookmarked_items.access_controlled_for(current_user, current_city, current_ability)
    render_paginated_feed :index
  end

  def create
    if params[:item_id].present?
      bookmark = Bookmark.new(:item_id => params[:item_id], :user => current_user)

      if bookmark.save
        flash[:notice] = "Item bookmarked."
      else
        flash[:error] = "An error occurred."
      end
    end

    redirect_to :back
  end

  def destroy
    if @bookmark.destroy
      flash[:notice] = "Bookmark removed"
    else
      flash[:error] = "An error occurred."
    end

    redirect_to :back
  end

private
  def load_resource
    @bookmark = Bookmark.find(params[:id])
  end
end

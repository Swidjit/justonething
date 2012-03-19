class BookmarksController < ApplicationController
  authorize_resource :only => :destroy
  before_filter :load_resource, :only => :destroy

  def index
    @bookmarks = Bookmark.for_user(current_user).all
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

class CommentsController < ApplicationController
  authorize_resource
  before_filter :load_resource, :only => :destroy

  def create
    comment = Comment.new params[:comment]
    comment.user = current_user
    comment.item_id = item_id_from_slug(params[:id])
    if comment.save
      flash[:notice] = 'Successfully commented on item'
    else
      flash[:notice] = 'Failed to comment on item'
    end
    if comment.item.present?
      redirect_to comment.item
    else
      redirect_to root_path
    end
  end
  
  def destroy
    if current_user == @comment.user || current_user = @comment.item.user
      if @comment.destroy
        flash[:notice] = "Comment removed"
      else
        flash[:error] = "An error occurred."
      end
    end

    redirect_to :back
  end
    
private
  def load_resource
    @comment = Comment.find(params[:id])
  end
end

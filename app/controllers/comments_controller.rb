class CommentsController < ApplicationController
  authorize_resource

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

end

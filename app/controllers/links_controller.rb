class LinksController < ApplicationController
  respond_to :html
  authorize_resource :only => :destroy

  def show
    @link = LinkDecorator.find(params[:id])
  end

  def new
    @link = Link.new
  end

  def create
    @link = Link.new(params[:link])
    @link.user ||= current_user
    @link.save
    respond_with @link
  end

  def destroy
    @link = Link.find(params[:id])
    @link.destroy
    flash[:notice] = "Link successfully deleted."
    if request.referer == link_url(params[:id])
      redirect_to root_path
    else
      redirect_to :back
    end
  end
end
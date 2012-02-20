class LinksController < ApplicationController
  respond_to :html
  authorize_resource :only => [:destroy, :edit, :update]
  before_filter :load_decorated_resource, :only => [:show,:edit,:update]

  def show
  end

  def new
    @link = LinkDecorator.new Link.new
  end

  def create
    @link = Link.new(params[:link])
    @link.user ||= current_user
    @link.save
    respond_with @link
  end

  def edit
  end

  def update
    @link.update_attributes(params[:link])
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

  private
  def load_decorated_resource
    @link = LinkDecorator.find(params[:id])
  end
end
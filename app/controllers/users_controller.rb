class UsersController < ApplicationController
  respond_to :html
  authorize_resource :only => :show
  before_filter :load_resource_by_url, :only => :show
  before_filter :load_resource, :only => [:edit, :update]

  def show
    item_type = params[:type] || 'all'
    if %w( events have_its want_its links thoughts ).include? item_type
      @feed_items = @user.items.where(:type => item_type.camelize.singularize).active.accessible_by(current_ability)
    else
      @feed_items = @user.items.active.accessible_by(current_ability)
    end
  end

  def edit
  end

  def update
    if @user.update_attributes(params[:user])
      redirect_to profile_path(@user.url)
    else
      render :edit
    end
  end

  private
  def load_resource
    @user = UserDecorator.find(params[:id])
  end

  def load_resource_by_url
    if params[:url].downcase != params[:url]
      redirect_to profile_path(params[:url].downcase)
    else
      @user = UserDecorator.decorate User.find_by_url(params[:url])
      raise ActiveRecord::RecordNotFound if @user.nil?
    end
  end
end

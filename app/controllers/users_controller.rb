class UsersController < ApplicationController
  respond_to :html
  authorize_resource :only => :show
  before_filter :load_resource_by_display_name, :only => :show
  before_filter :load_resource, :only => [:edit, :update]

  def show
    item_type = params[:type] || 'all'
    if %w( events have_its want_its links thoughts ).include? item_type
      @feed_items = @user.items.where(:type => item_type.camelize.singularize).access_controlled_for(current_user,current_ability)
    else
      params[:type] = 'all'
      @feed_items = @user.items.access_controlled_for(current_user,current_ability)
    end
  end

  def edit
  end

  def update
    if @user.update_attributes(params[:user])
      redirect_to profile_path(@user.display_name)
    else
      render :edit
    end
  end

  private
  def load_resource
    @user = UserDecorator.find(params[:id])
  end

  def load_resource_by_display_name
    @user = UserDecorator.decorate User.by_lower_display_name(params[:display_name])
    raise ActiveRecord::RecordNotFound if @user.nil?
    if @user.display_name != params[:display_name]
      redirect_to profile_path(@user.display_name)
    end
  end
end

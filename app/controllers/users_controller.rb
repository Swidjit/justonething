class UsersController < ApplicationController
  respond_to :html, :json
  authorize_resource :only => :show
  before_filter :load_resource_by_display_name, :only => :show
  before_filter :load_resource, :only => [:edit, :update, :references]

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

  def references
    item_type = params[:type] || 'all'
    if %w( events have_its want_its links thoughts ).include? item_type
      @feed_items = Item.referencing(@user).where(:type => item_type.camelize.singularize).access_controlled_for(current_user,current_ability)
    else
      params[:type] = 'all'
      @feed_items = Item.referencing(@user).access_controlled_for(current_user,current_ability)
    end
  end

  def visibility_options
    item = Item.new

    # 0 is used as a placeholder for current user
    if params[:id].present? && params[:id].to_i > 0
      user = User.find(params[:id])
      item.user = user
    end

    @item = ItemDecorator.new(item)

    render :partial => 'items/visibility_form', :locals => { :ajax => false, :item => @item }
  end

  def suggestions
    # familiar users
    users = current_user.familiar_users.lower_display_name_like(params[:id]).all(:select => 'display_name')

    # all users
    users = User.lower_display_name_like(params[:id]).all(:select => 'display_name') if @users.blank?

    display_names = users.map(&:display_name)

    respond_with(display_names) do |format|
      format.json { render :json => { :users => display_names } }
    end
  end

  private
  def load_resource
    @user = UserDecorator.find(params[:id])
  end

  def load_resource_by_display_name
    @user = UserDecorator.decorate User.by_lower_display_name(params[:display_name])
    if @user.model.nil?
      @object = "User Profile for #{params[:display_name]}"
      render 'errors/404', :status => 404
    else
      if @user.display_name != params[:display_name]
        redirect_to profile_path(@user.display_name)
      end
    end
  end
end

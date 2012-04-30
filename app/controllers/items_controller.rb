class ItemsController < ApplicationController
  respond_to :html, :json
  authorize_resource :only => [:destroy, :edit, :update, :add_visibility_rule,
    :remove_visibility_rule]
  before_filter :load_decorated_resource
  before_filter :load_preset_tags, :only => [:new, :edit, :update, :duplicate, :create]
  before_filter :authorize_create_item, :only => [:create,:new]
  before_filter :arrayify_ids_fields_in_params, :only => [:create,:update]
  before_filter :load_comments, :only => :show

  def show
  end

  def new
    if params[:community_id].present?
      @item.communities << Community.find(params[:community_id])
    end
    if current_user.cities.any?
      @item.item_visibility_rules.build(:visibility_id => current_user.cities.first.id, :visibility_type => 'City')
      @item.cities << current_user.cities.first
    end
    respond_to do |f|
      f.html { render :new }
      f.js { render 'new', :format => :html, :layout => false}
    end
  end

  def create
    if item_params[:user_id].present?
      @item.posted_by_user = current_user
      @item.user = User.find(item_params[:user_id])
    else
      @item.user = current_user
    end

    item_params.delete(:user_id)

    @item.assign_attributes(item_params)

    format_expires_on
    @item.save
    respond_with @item
  end

  def edit
  end

  def update
    @item.assign_attributes(item_params)
    format_expires_on
    @item.save
    respond_with @item
  end

  def destroy
    @item.destroy
    flash[:notice] = "#{item_class.to_s.titleize} successfully deleted."
    # if deleted from show go to root else go back to feed
    if request.referer == send("#{item_class.to_s.underscore}_url",params[:id])
      redirect_to root_path
    else
      redirect_to :back
    end
  end

  def toggle_active
    if @item.active
      @item.active = false
    else
      @item.active = true
    end
    @item.save(:validate => false)
    if request.referer.present?
      redirect_to :back
    else
      redirect_to item_path(@item)
    end
  end

  def duplicate
    item_to_duplicate = item_class.find(params[:id])
    @item = item_decorator.decorate item_to_duplicate.dup
    @item.tags = item_to_duplicate.tags
    @item.set_defaults
    render :new
  end

  def add_visibility_rule
    if %( community list city ).include? params[:visibility_type]
      rule_obj = params[:visibility_type].camelize.constantize.find(params[:visibility_id])
      @item.send(params[:visibility_type].pluralize) << rule_obj
    end
    respond_to do |f|
      f.json { render :json => {:success => @item.valid?, :item => @item.to_json} }
    end
  end

  def remove_visibility_rule
    if %( community list city ).include? params[:visibility_type]
      rule_obj = params[:visibility_type].camelize.constantize.find(params[:visibility_id])
      @item.send(params[:visibility_type].pluralize).destroy rule_obj
    end
    respond_to do |f|
      f.json { render :json => {:success => @item.valid?, :item => @item.to_json} }
    end
  end

  def flag
    @item.flag!(current_user)
    redirect_to :back
  end

private
  def arrayify_ids_fields_in_params
    ic_sym = item_class.to_s.underscore.to_sym
    %w( community_ids list_ids ).each do |ids_field|
      if params[ic_sym][ids_field].present? && params[ic_sym][ids_field].is_a?(String)
        params[ic_sym][ids_field] = params[ic_sym][ids_field].split(',')
      end
    end
  end

  def authorize_create_item
    authorize! :create, Item
  end

  def item_decorator
    (item_class.to_s + "Decorator").constantize
  end

  def load_comments
    @comments = @item.comments.roots
  end

  def load_decorated_resource
    if params[:id].present?
      item_id = params[:id].split('-').last
      # Ensure only active items can be seen in show
      if params[:action] == 'show'
        @item = item_decorator.decorate item_class.active.find item_id
      else
        @item = item_decorator.find item_id
      end
    else
      @item = item_decorator.new item_class.new
    end
  end

  def load_preset_tags
    @item_preset_tags = ItemPresetTag.where(:item_type => item_class.to_s)
  end

  def format_expires_on
    if item_params[:has_expiration].to_i == 1 && item_params[:expires_on].present?
      @item.expires_on = Date.strptime(item_params[:expires_on],'%m/%d/%Y')
    end
  end

  def item_class
    raise 'Override item_class in the child controller with the class for that type'
  end

  def item_params
    params[item_class.to_s.underscore.to_sym]
  end
end

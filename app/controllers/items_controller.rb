class ItemsController < ApplicationController
  respond_to :html
  authorize_resource :only => [:destroy, :edit, :update]
  before_filter :load_decorated_resource
  before_filter :authorize_create_item, :only => [:create,:new]

  def show
  end

  def new
    if params[:community_id].present?
      @item.communities << Community.find(params[:community_id])
    end
  end

  def create
    @item.assign_attributes(params[item_class.to_s.underscore.to_sym])
    format_expires_on
    @item.user ||= current_user
    @item.save
    respond_with @item
  end

  def edit
  end

  def update
    @item.assign_attributes(params[item_class.to_s.underscore.to_sym])
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
    redirect_to :back
  end

  def duplicate
    item_to_duplicate = item_class.find(params[:id])
    @item = item_decorator.decorate item_to_duplicate.dup
    @item.tags = item_to_duplicate.tags
    @item.set_defaults
    render :new
  end

  private
  def authorize_create_item
    authorize! :create, Item
  end

  def item_decorator
    (item_class.to_s + "Decorator").constantize
  end

  def load_decorated_resource
    if params[:id].present?
      @item = item_decorator.find params[:id]
    else
      @item = item_decorator.new item_class.new
    end
  end

  def format_expires_on
    if @item.has_expiration == '1' && @item.expires_on.present?
      @item.expires_on = Date.strptime(params[item_class.to_s.underscore.to_sym][:expires_on],'%m/%d/%Y')
    end
  end

  def item_class
    raise 'Override item_class in the child controller with the class for that type'
  end
end
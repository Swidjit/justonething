class ListsController < ApplicationController

  respond_to :json, :html

  load_and_authorize_resource :only => [:show,:destroy]

  before_filter :load_and_authorize_list, :only => [:add_user,:delete_user]

  def show
    item_type = params[:type] || 'all'
    if %w( events have_its want_its links thoughts ).include? item_type
      item_class = item_type.camelize.singularize.constantize
    else
      params[:type] = 'all'
      item_class = Item
    end
    @feed_items = item_class.access_controlled_for(current_user,current_ability).find_all_by_user_id(@list.users.collect(&:id))
  end

  def create
    @list = List.new
    @list.name = params[:list][:name]
    @list.user = current_user
    @list.save
    respond_with @list
  end

  def destroy
    @list.destroy
    redirect_to root_path
  end

  def add_user
    user = User.find(params[:user_id])
    if @list.users.include?(user)
      notice = "User already in list #{@list.name}"
    else
      @list.users << user
      notice = "Successfully added user to #{@list.name}"
    end
    respond_to do |f|
      f.json { render :json => {:notice => notice, :success => true }}
    end
  end

  def delete_user
    user_to_remove = ListsUser.find_by_user_id_and_list_id(params[:user_id], @list.id)
    if user_to_remove.present?
      @list.lists_users.destroy(user_to_remove)
      message = 'Successfully removed user'
    else
      message = 'User not in list'
    end
    respond_to do |f|
      f.json { render :json => {:notice => message, :success => true }}
    end
  end

private
  def load_and_authorize_list
    @list = List.find(params[:id])
    if !can? :manage, @list
      respond_to do |f|
        f.json { render :json => {:notice => 'You are not authorized to do this.', :success => false}}
      end
    end
  end

end

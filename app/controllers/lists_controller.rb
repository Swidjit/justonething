class ListsController < ApplicationController

  respond_to :json, :html

  load_and_authorize_resource :only => [:show]

  before_filter :load_and_authorize_list, :only => [:add_user,:delete_user]

  def show
    @feed_items = Item.find_all_by_user_id(@list.users.map(&:id))
  end

  def create
    @list = List.new
    @list.name = params[:list][:name]
    @list.user = current_user
    @list.save
    respond_with @list
  end

  def add_user
    @list.users << User.find(params[:user_id])
    respond_to do |f|
      f.json { render :json => {:notice => 'Successfully added user', :success => true }}
    end
  end

  def delete_user
    @list.users.destroy(User.find(params[:user_id]))
    respond_to do |f|
      f.json { render :json => {:notice => 'Successfully removed user', :success => true }}
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

class SuggestedItemsController < ApplicationController
  
  authorize_resource :only => :destroy
  before_filter :load_resource, :only => :destroy
 
  def new
    @suggested_item = SuggestedItem.new
  end
  
  def create  
    if params[:item_id].present?
      @suggested_item = SuggestedItem.new(:item_id => params[:item_id],:user => current_user)
      @suggested_item.suggested_user_id = User.find_by_display_name(params[:user_list]).id
      u = params[:user_list]
      #debugger
      if @suggested_item.save
        flash[:notice] = "Item suggested."
      else
        flash[:error] = "An error occurred."
      end 
      redirect_to :back
    else
      redirect_to :back 
    end
  end
  
end

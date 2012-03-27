class OffersController < ApplicationController
  before_filter :load_and_authorize_offer, :only => :index

  def create
  end

  def index
    render :partial => 'offer', :layout => false
  end

private

  def load_and_authorize_offer
    user = params[:user_id].present? ? User.find(params[:user_id]) : current_user
    item = Item.find(params[:item_id])
    @offer = Offer.find(:first, :conditions => { :user_id => user.id, :item_id => item.id })

    authorize! :read, @offer
  end
end

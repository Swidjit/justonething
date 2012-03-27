class OffersController < ApplicationController
  before_filter :load_and_authorize_offer, :only => [:index, :update]

  def create
  end

  def index
    render :partial => 'offer', :layout => false
  end

private

  def load_and_authorize_offer
    item_id = params[:item_id]
    user_id = params[:user_id] || current_user.id
    @offer = Offer.find(:first, :conditions => { :user_id => user_id, :item_id => item_id })

    authorize! :read, @offer
  end
end

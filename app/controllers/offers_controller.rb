class OffersController < ApplicationController
  before_filter :load_and_authorize_offer, :only => :index

  def create
    offer = Offer.create(:item_id => params[:item_id], :user => current_user)
    OfferMessage.create(:offer => offer, :user => current_user, :text => params[:text])
    redirect_to :back
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

class OffersController < ApplicationController
  def create
    offer = Offer.create(:item_id => params[:item_id], :user => current_user)
    OfferMessage.create(:offer_id => offer.id, :user => current_user, :text => params[:text])
    redirect_to :back
  end

  def index
    # nested within items
    if params[:item_id].present?
      load_and_authorize_offer
      render :partial => 'offer', :layout => false

    # nested within users
    else
      load_all_offers_for_current_user
    end
  end

private

  def load_and_authorize_offer
    item_id = params[:item_id]
    user_id = params[:user_id] || current_user.id
    @offer = Offer.find(:first, :conditions => { :user_id => user_id, :item_id => item_id })

    authorize! :read, @offer
  end

  def load_all_offers_for_current_user
    user_id = current_user.id
    @offers = Offer.for_user(current_user)
  end
end

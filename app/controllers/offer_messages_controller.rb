class OfferMessagesController < ApplicationController
  before_filter :load_and_authorize_offer, :only => :create

  def create
    OfferMessage.create(:offer => @offer, :user => current_user, :text => params[:offer_message][:text])
    redirect_to :back
  end

private

  def load_and_authorize_offer
    @offer = Offer.find_by_id(params[:offer_id])
    authorize! :update, @offer
  end
end

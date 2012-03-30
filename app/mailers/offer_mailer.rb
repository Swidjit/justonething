class OfferMailer < ActionMailer::Base
  default from: "swidjit@swidjit.com"

  def new_offer_email(offer)
    @offer = offer
    @item = offer.item
    to = @item.user.email

    mail(:to => to, :subject => "You just received an offer on #{@item.title}")
  end
end

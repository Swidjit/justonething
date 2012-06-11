class OfferMailer < ActionMailer::Base
  default from: "swidjit@swidjit.com"

  def new_offer_email(offer)
    @offer = offer
    @item = offer.item
    @item_url = send("#{@item.class.to_s.underscore}_url",@item.user.cities.first,@item)
    to = @item.user.email
    subject = (offer.messages.count == 1) ? "You just received an offer on #{@item.title}" :
                                            "You just received a message on an offer on #{@item.title}"
    mail(:to => to, :subject => subject)
  end
end

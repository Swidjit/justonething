class NotificationDecorator < ApplicationDecorator
  decorates :notification

  def linked_sender
    h.link_to("@#{notification.sender.display_name}",h.profile_path(notification.sender.display_name))
  end

  def middle_text
    case notification.notifier_type
      when 'Comment'
        'has commented on your item'
      when 'Offer'
        'has made an offer on your item'
      when 'Recommendation'
        'has recommended your item'
      when 'CommunityInvitation'
        'has invited you to join'
      when 'OfferMessage'
        if notification.notifier.offer.user_id == notification.receiver_id
          'has replied to your offer on their item'
        else
          'has replied to their offer on your item'
        end
    end
  end

  def notifier_link
    target = notification.notifier
    case notification.notifier_type
      when 'Comment','Offer','Recommendation'
        h.link_to(target.item.title,h.send("#{target.item.class.to_s.underscore}_path",target.item))
      when 'OfferMessage'
        h.link_to(target.offer.item.title,h.send("#{target.offer.item.class.to_s.underscore}_path",target.offer.item))
      when 'CommunityInvitation'
        h.link_to(target.community.name,h.community_path(target.community))
    end
  end

  def user_friendly_type
    case notification.notifier_type
      when 'Comment'
        'comment'
      when 'Offer'
        'offer'
      when 'Recommendation'
        'recommendation'
      when 'CommunityInvitation'
        'invitation'
      when 'OfferMessage'
        'offer reply'
    end
  end
end
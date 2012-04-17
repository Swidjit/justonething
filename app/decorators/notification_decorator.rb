class NotificationDecorator < ApplicationDecorator
  decorates :notification

  def linked_sender
    h.link_to("@#{notification.sender.display_name}",h.profile_path(notification.sender.display_name))
  end

  def middle_text
    if notification.is_mention?
      case notification.notifier_type
        when 'Comment','Recommendation'
          "has mentioned you in their #{notification.notifier_type.humanize.downcase} on the item"
        else
          "has mentioned you in their #{notification.notifier_type.humanize.downcase}"
      end
    else
      case notification.notifier_type
        when 'Comment'
          if notification.notifier.is_root?
            'has commented on your item'
          else
            'has replied to your comment on the item'
          end
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
        when 'Delegate'
          'has added you as a delegate, you can now post items as them'
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
      when 'Delegate'
        '' # No link for this
      when 'Item','HaveIt','WantIt','Event','Thought','Link','Collection'
        h.link_to(target.title,h.send("#{target.class.to_s.underscore}_path",target))
    end
  end

  def user_friendly_type
    if notification.is_mention?
      'mention'
    else
      case notification.notifier_type
        when 'Comment','Offer','Recommendation'
          notification.notifier_type.downcase
        when 'CommunityInvitation'
          'invitation'
        when 'OfferMessage'
          'offer reply'
        when 'Delegate'
          'delegation'
      end
    end
  end
end
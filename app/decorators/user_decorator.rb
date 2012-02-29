class UserDecorator < ApplicationDecorator
  decorates :user

  def manage_links
    if h.can? :manage, user
      h.link_to 'Edit Profile', h.edit_user_path(user)
    end
  end
end
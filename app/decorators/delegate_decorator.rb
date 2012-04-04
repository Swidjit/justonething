class DelegateDecorator < ApplicationDecorator
  decorates :delegate
  include Draper::LazyHelpers

  def delegatee_display_name_with_remove_link
    "<span>".html_safe + delegate.delegatee.display_name + " " + link_to("x", delegate_path(delegate), :class => 'remove_user_from_delegates').html_safe + "</span>".html_safe
  end
end

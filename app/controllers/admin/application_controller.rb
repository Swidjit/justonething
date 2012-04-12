class Admin::ApplicationController < ApplicationController
  before_filter :require_admin

private

  def require_admin
    current_user.present? && current_user.is_admin?
  end
end

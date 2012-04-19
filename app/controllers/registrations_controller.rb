class RegistrationsController < Devise::RegistrationsController

  def after_inactive_sign_up_path_for(resource)
    new_user_session_path
  end

  def build_resource(hash=nil)
    hash ||= params[resource_name] || {}
    self.resource = resource_class.new_with_session(hash, session)
    if self.resource.email.present? && session['skip_confirmation_for'].present? &&
        self.resource.email == session['skip_confirmation_for']
      self.resource.skip_confirmation!
    end
  end

end

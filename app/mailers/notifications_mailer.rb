class NotificationsMailer < ActionMailer::Base
  default from: "swidjit@swidjit.com"
  default :to => "alex@swidjit.com"

  def new_message(message)
    @message = message
    mail(:subject => message.subject, :from => message.email)
  end
end

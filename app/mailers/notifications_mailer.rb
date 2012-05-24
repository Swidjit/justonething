class NotificationsMailer < ActionMailer::Base
  default from: "swidjit@swidjit.com"
  default :to => "alex@swidjit.com"
  default :bcc => "sonny@singlebrook.com"

  def new_message(message)
    @message = message
    mail(:subject => message.subject, :from => message.email, :reply_to => message.email)
  end
end

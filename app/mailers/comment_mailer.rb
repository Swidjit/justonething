class CommentMailer < ActionMailer::Base
  default from: "swidjit@swidjit.com"

  def new_comment_email(item, recipient, commenter, comment_text)
    @comment_text = comment_text
    @item = item
    @item_url = send("#{@item.class.to_s.underscore}_url",@item.user.cities.first,@item)
    to = recipient.email

    mail(:to => to, :subject => "You just received a comment on #{@item.title}")
  end

  def new_comment_reply_email(item, recipient, commenter, comment_text)
    @comment_text = comment_text
    @item = item
    @item_url = send("#{@item.class.to_s.underscore}_url",@item.user.cities.first,@item)
    to = recipient.email

    mail(:to => to, :subject => "You just received a reply to your comment on #{@item.title}")
  end
end

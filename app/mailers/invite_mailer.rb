class InviteMailer < ActionMailer::Base
  default from: "swidjit@swidjit.com"

  def community_invite(to, from, community)
    subj = "#{from.full_name} wants to invite you to a community on Swidjit"
    @from = from
    @community = community
    @to = to
    mail(:to => to.email, :subject => subj)
  end
end
namespace :daily do
  
  task feeds: :environment do
    Time.zone = 'Eastern Time (US & Canada)'
    Feed.process!
    Reminder.send_for_date Date.today
  end
  
end
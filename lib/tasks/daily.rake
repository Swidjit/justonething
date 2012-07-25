namespace :daily do
  
  task feeds: :environment do
    Feed.process!
    Reminder.send_for_date Date.today
  end
  
end
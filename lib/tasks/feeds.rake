namespace :feeds do
  
  task default: :environment do
    Feed.process!
  end
  
end
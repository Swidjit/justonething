namespace :user_familiarity do
  desc 'Update user familiarity for all users'
  task :update_all => :environment do
    UserFamiliarity.update_all_users
    puts 'Updated all User Familiarities'
  end
end
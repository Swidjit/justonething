class AddDefaultLocationToFeeds < ActiveRecord::Migration
  def change
    change_table :feeds do |t|
      t.string :location, after: :url
    end
  end
end

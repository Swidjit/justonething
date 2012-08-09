class AddFeedToEvent < ActiveRecord::Migration
  def change
    change_table :items do |t|
      t.references :feed
    end
    change_table :items do |t|
      t.index :feed_id
    end
  end
end

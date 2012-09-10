class CreateCustomFeeds < ActiveRecord::Migration
  def up
    create_table :custom_feeds do |t|
      t.string :name, :null => false
      t.references :user
      t.string :description

      t.timestamps
    end

    add_index :custom_feeds, :user_id
  end
  def down
    drop_table :custom_feeds
  end
end

class CreateBookmarksTable < ActiveRecord::Migration
  def up
    create_table :bookmarks do |t|
      t.integer :user_id
      t.integer :item_id

      t.timestamps
    end

    add_foreign_key :bookmarks, :users
    add_foreign_key :bookmarks, :items
  end

  def down
  end
end

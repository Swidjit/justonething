class AddIndexToBookmarksItemId < ActiveRecord::Migration
  def change
    add_index :bookmarks, :item_id
  end
end

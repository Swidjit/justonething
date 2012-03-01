class AddIndecesToLinkingTables < ActiveRecord::Migration
  def change
    add_index :communities_users, :community_id

    add_index :items_tags, :tag_id
  end
end

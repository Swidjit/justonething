class AllowFeedsToHaveTags < ActiveRecord::Migration
  def change
    create_table "feeds_tags", :id => false, :force => true do |t|
      t.integer "feed_id", :null => false
      t.integer "tag_id",  :null => false
    end

    add_index "feeds_tags", ["feed_id", "tag_id"], :name => "index_feeds_tags_on_feed_id_and_tag_id", :unique => true
    add_index "feeds_tags", ["tag_id"], :name => "index_feeds_tags_on_tag_id"
  end

end

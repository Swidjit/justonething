class CreateCustomFeedElements < ActiveRecord::Migration
  def up
    create_table :custom_feed_elements, :id => false do |t|
      t.references :custom_feed, :null => false
      t.string :element_type, :null => false
      t.string :element_name, :null => false
    end

    add_index :custom_feed_elements, :custom_feed_id
  end
  def down
    drop_table :custom_feed_elements
  end
end

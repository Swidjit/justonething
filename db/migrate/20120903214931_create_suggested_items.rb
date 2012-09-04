class CreateSuggestedItems < ActiveRecord::Migration
  def up
    create_table :suggested_items do |t|
      t.integer :item_id      
      t.integer :user_id
      t.text :message
      t.integer :suggested_user_id

      t.timestamps
    end
    
    add_foreign_key :suggested_items, :users
    add_foreign_key :suggested_items, :items
    
  end
  
  def down
    drop_table :suggested_items
    remove_foreign_key :suggested_items, :users
    remove_foreign_key :suggested_items, :items
  end
end

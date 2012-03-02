class CreateItemVisibilityRules < ActiveRecord::Migration
  def change
    create_table :item_visibility_rules do |t|
      t.integer :visibility_id, :null => false
      t.string :visibility_type, :null => false
      t.references :item, :null => false
    end

    add_index :item_visibility_rules, [:visibility_id,:visibility_type,:item_id],
        { :unique => true, :name => 'uniq_item_visibility_index' }
    add_index :item_visibility_rules, :item_id
  end
end

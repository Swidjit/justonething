class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.references :item, :null => false
      t.references :user, :null => false
      t.text :text, :null => false
      t.string :ancestry

      t.timestamps
    end

    add_index :comments, :item_id
    add_index :comments, :user_id
    add_index :comments, :ancestry
  end
end

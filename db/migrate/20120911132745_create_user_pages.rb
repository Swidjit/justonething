class CreateUserPages < ActiveRecord::Migration
  def up
    create_table :user_pages do |t|
      t.string :name
      t.text :body
      t.references :user
      t.integer :position
      t.boolean :active

      t.timestamps
    end
    add_index :user_pages, :user_id
  end
  def down
    drop_table :user_pages 
  end
end

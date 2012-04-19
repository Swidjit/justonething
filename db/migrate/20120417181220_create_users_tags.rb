class CreateUsersTags < ActiveRecord::Migration
  def change
    create_table :users_tags do |t|
      t.integer :user_id, :null => false
      t.integer :tag_id, :null => false
    end

    add_foreign_key :users_tags, :users
    add_foreign_key :users_tags, :tags
  end
end

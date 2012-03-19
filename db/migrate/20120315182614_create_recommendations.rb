class CreateRecommendations < ActiveRecord::Migration
  def change
    create_table :recommendations do |t|
      t.text :description
      t.references :user, :null => false
      t.references :item, :null => false

      t.timestamps
    end

    add_index :recommendations, [:item_id,:user_id], :unique => true
  end
end

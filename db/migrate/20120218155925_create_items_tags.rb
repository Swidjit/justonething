class CreateItemsTags < ActiveRecord::Migration
  def change
    create_table :items_tags, :id => false do |t|
      t.references :item, :null => false
      t.references :tag, :null => false
    end

    add_index(:items_tags, [:item_id, :tag_id], :unique => true)
  end
end

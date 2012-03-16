class CreateItemPresetTags < ActiveRecord::Migration
  def change
    create_table :item_preset_tags do |t|
      t.string :tag
      t.string :item_type
    end
  end
end

class AddIsImportedToItems < ActiveRecord::Migration
  def change
    change_table :items do |t|
      t.boolean :imported, default: false, null: false
    end
  end
end

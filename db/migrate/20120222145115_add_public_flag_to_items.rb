class AddPublicFlagToItems < ActiveRecord::Migration
  def change
    add_column :items, :public, :boolean, :null => false, :default => true

  end
end

class DropPublicFromItems < ActiveRecord::Migration
  def up
    remove_column :items, :public
  end

  def down
    add_column :items, :public, :boolean, :default => true, :null => false
  end
end

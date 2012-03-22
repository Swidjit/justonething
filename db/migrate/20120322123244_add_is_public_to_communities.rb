class AddIsPublicToCommunities < ActiveRecord::Migration
  def change
    add_column :communities, :is_public, :boolean, :null => false, :default => true

  end
end

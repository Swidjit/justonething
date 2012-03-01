class CreateCommunitiesUsers < ActiveRecord::Migration
  def change
    create_table :communities_users, :id => false do |t|
      t.references :user, :null => false
      t.references :community, :null => false
    end

    add_index(:communities_users, [:user_id, :community_id], :unique => true)
  end
end

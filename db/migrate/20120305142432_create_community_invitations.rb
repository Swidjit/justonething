class CreateCommunityInvitations < ActiveRecord::Migration
  def change
    create_table :community_invitations do |t|
      t.integer :invitee_id, :null => false
      t.integer :inviter_id, :nul => false
      t.references :community
      t.column :status, 'char(1)', :default => 'P'

      t.timestamps
    end
  end
end

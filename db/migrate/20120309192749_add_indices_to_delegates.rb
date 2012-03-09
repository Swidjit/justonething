class AddIndicesToDelegates < ActiveRecord::Migration
  def change
   add_index :delegates, [:delegator_id, :delegatee_id], :unique => true
   add_index :delegates, :delegatee_id
  end
end

class CreateDelegates < ActiveRecord::Migration
  def change
    create_table :delegates do |t|
      t.references :delegator
      t.references :delegatee

      t.timestamps
    end

    add_foreign_key :delegates, :users, :column => :delegator_id
    add_foreign_key :delegates, :users, :column => :delegatee_id
  end
end

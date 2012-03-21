class CreateVouches < ActiveRecord::Migration
  def change
    create_table :vouches do |t|
      t.integer :voucher_id
      t.integer :vouchee_id

      t.timestamps
    end

    add_index :vouches, [:voucher_id, :vouchee_id], :unique => true
    add_index :vouches, :vouchee_id
  end
end

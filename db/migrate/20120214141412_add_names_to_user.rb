class AddNamesToUser < ActiveRecord::Migration
  def change
    add_column :users, :first_name, :string

    add_column :users, :last_name, :string

    add_column :users, :display_name, :string

  end
end

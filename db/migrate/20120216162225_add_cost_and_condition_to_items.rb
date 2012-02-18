class AddCostAndConditionToItems < ActiveRecord::Migration
  def change
    add_column :items, :cost, :string

    add_column :items, :condition, :string

  end
end

class ChangeOfferMessageDataType < ActiveRecord::Migration
  def up
    change_table :offer_messages do |t|
      t.change :text, :text
    end
  end

  def down
    change_table :offer_messages do |t|
      t.change :text, :string
    end
  end
end

class CreateCities < ActiveRecord::Migration
  def change
    create_table :cities do |t|
      t.string :url_name
      t.string :display_name
    end
  end
end

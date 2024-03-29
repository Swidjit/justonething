# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

ithaca = City.create({ url_name: 'ithaca', display_name: 'Ithaca'})
Item.all.each do |itm|
  itm.item_visibility_rules.create({:visibility_type => 'City', :visibility_id => ithaca.id})
end
User.all.each do |usr|
  usr.cities << ithaca
end
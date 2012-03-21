# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :comment do
    text "Something random"
    user { |a| a.association(:user) }
    item { |a| a.association(:have_it) }
  end

  factory :nest_comment, :parent => :comment do
    parent { |a| a.association(:comment) }
  end
end

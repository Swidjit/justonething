# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :vouch do
    voucher { |a| a.association(:voucher) }
    vouchee { |a| a.association(:vouchee) }
  end
end

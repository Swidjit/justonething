require "#{Rails.root}/spec/support/image_paths"
include Swidjit::TestHelpers::ImagePaths

FactoryGirl.define do
  factory :image do
    file { small_test_image }
  end
end
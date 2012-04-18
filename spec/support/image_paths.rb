module Swidjit
  module TestHelpers
    module ImagePaths
      def small_test_image
        File.new(small_test_image_path)
      end

      def small_test_image_path
        "#{Rails.root}/spec/support/fixtures/images/#{small_test_image_filename}"
      end

      def small_test_image_filename
        "ipad.jpg"
      end
    end
  end
end
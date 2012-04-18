require 'spec_helper'

describe Image do
  subject { build :image }

  it "supports reading and writing a file via Dragonfly" do
    subject.file = File.new(small_test_image_path)
    subject.file.should be_a Dragonfly::ActiveModelExtensions::Attachment
  end

  describe "validations" do
    it "has a valid Factory" do
      subject.should be_valid
    end

    it "is not valid without a file" do
      subject.file = nil
      subject.should_not be_valid
    end
  end
end
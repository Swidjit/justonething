require 'spec_helper'

describe ImageDecorator do
  let(:decorator) { ImageDecorator.new(image) }
  let(:image)     { stub :id => 5, :file => image_file }

  # Supporting stubs to mock out Dragonfly behavior.
  let(:image_file) { stub :url => "full_image.png", :thumb => thumb }
  let(:thumb)      { stub :url => "thumbnail_image.png" }

  describe "thumbnail convenience methods:" do
    it "can render a thumbnail at a given size" do
      image_file.should_receive(:thumb).with('100x150')

      image_html = "<img alt=\"Thumbnail_image\" src=\"/assets/thumbnail_image.png\" />"
      decorator.thumb('100x150').should == image_html
    end

    it "renders a 150 width thumbnail by default" do
      image_file.should_receive(:thumb).with('150x150>')
      decorator.thumb
    end
  end

  describe "JSON rendering:" do
    it "can render itself as JSON" do
      expected_json = { "id"  => 5,
                        "url" => "full_image.png" }.to_json
      decorator.to_json.should == expected_json
    end

    it "can render itself as JSON with a specific size" do
      expected_json = { "id"  => 5,
                        "url" => "thumbnail_image.png" }.to_json
      image_file.should_receive(:thumb).with('122x212')

      decorator.to_json('122x212').should == expected_json
    end
  end
end
require 'spec_helper'

describe ImagesController do
  describe "GET :generate" do
    it "creates an image using the file specified in the image_param" do
      image = stub.as_null_object
      Image.should_receive(:create)
           .with(:file => 'file')
           .and_return(image)
      get :generate, 'image_param' => 'image_file', 'image_file' => 'file'
    end

    it "decorates the image" do
      image = stub
      Image.stub :create => image
      ImageDecorator.should_receive(:new).with(image)
      get :generate
    end

    it "renders the decorated image as JSON" do
      image = stub
      ImageDecorator.stub :new => image
      image.should_receive(:to_json).and_return("Image as JSON")
      get :generate
      response.body.should == "Image as JSON"
    end
  end
end

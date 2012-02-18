require 'spec_helper'

describe Link do
  describe "supports reading and writing:" do
    it "a link" do
      subject.link = 'http://example.com'
      subject.link.should == 'http://example.com'
    end
  end
end

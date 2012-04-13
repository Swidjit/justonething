require 'spec_helper'

describe TagsController do
  it "does not blow up when getting a list of tags" do
    get :autocomplete_search, :q => 's', :format => :json
  end

  it "does not blow up when getting a list of geo tags" do
    get :autocomplete_search_geo, :q => 's', :format => :json
  end
end

step "I visit a Community I didn't create" do
  @community = Factory(:community)
  visit community_path(@community)
end

step 'I click Join' do
  click_link 'Join'
end

step 'the Want It should be linked to the Community' do
  @want_it.reload
  @want_it.communities.should == [@community]
end
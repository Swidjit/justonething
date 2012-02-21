step 'I click the link to Post a Link' do
  click_link 'post_link'
end

step 'the Link should be posted' do
  Link.count.should == 1
  @link = Link.first
  current_path.should == link_path(@link)
end

step "I visit a Link I posted" do
  @link = Factory(:link, :user => @current_user)
  visit link_path(@link)
end

step 'the Link should be deleted' do
  Link.find_all_by_id(@link.id).count.should == 0
end

step 'the Link should be updated' do
  @link.reload
  @link.updated_at.should_not == @link.created_at
end